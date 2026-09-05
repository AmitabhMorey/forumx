module Search
  class SearchService
    attr_reader :query, :category_slug, :tag_slug, :author_username, :sort_by

    def initialize(query: nil, category_slug: nil, tag_slug: nil, author_username: nil, sort_by: "relevance")
      @query = query.to_s.strip
      @category_slug = category_slug.presence
      @tag_slug = tag_slug.presence
      @author_username = author_username.presence
      @sort_by = sort_by.presence || "relevance"
    end

    def discussions
      scope = Discussion.includes(:user, :category, :tags)

      # 1. Full-text search
      if query.present?
        # Clean query for tsquery
        sanitized_terms = query.gsub(/[^a-zA-Z0-9\s]/, "").split.map { |term| "#{term}:*" }.join(" & ")

        if sanitized_terms.present?
          scope = scope.where(
            "to_tsvector('english', coalesce(discussions.title, '') || ' ' || coalesce(discussions.body, '')) @@ to_tsquery('english', ?)",
            sanitized_terms
          )

          # Rank results if relevance sort
          if sort_by == "relevance"
            scope = scope.order(
              Arel.sql(
                ActiveRecord::Base.sanitize_sql_array([
                                                        "ts_rank(to_tsvector('english', coalesce(discussions.title, '') || ' ' || coalesce(discussions.body, '')), to_tsquery('english', ?)) DESC, discussions.created_at DESC",
                                                        sanitized_terms
                                                      ])
              )
            )
          end
        end
      end

      # 2. Filters
      if category_slug.present?
        category = Category.find_by(slug: category_slug)
        scope = scope.where(category: category) if category
      end

      if tag_slug.present?
        tag = Tag.find_by(slug: tag_slug)
        scope = scope.joins(:tags).where(tags: { id: tag.id }) if tag
      end

      if author_username.present?
        user = User.find_by(username: author_username)
        scope = scope.where(user: user) if user
      end

      # 3. Custom sorting
      case sort_by
      when "latest"
        scope.latest
      when "trending"
        scope.trending
      when "votes"
        scope.most_votes
      when "replies"
        scope.most_replies
      when "views"
        scope.most_viewed
      else
        query.blank? ? scope.latest : scope
      end
    end

    def users
      return User.none if query.blank?

      sanitized = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      User.active.where("username ILIKE ? OR display_name ILIKE ?", sanitized, sanitized).order(reputation: :desc).limit(10)
    end

    def tags
      return Tag.none if query.blank?

      sanitized = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      Tag.where("name ILIKE ?", sanitized).order(discussions_count: :desc).limit(10)
    end

    def categories
      return Category.none if query.blank?

      sanitized = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      Category.where("name ILIKE ? OR description ILIKE ?", sanitized, sanitized).order(:position).limit(10)
    end
  end
end

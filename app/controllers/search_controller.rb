class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @category_slug = params[:category]
    @tag_slug = params[:tag]
    @author_username = params[:author]
    @sort_by = params[:sort].presence || (@query.present? ? "relevance" : "latest")

    @search_service = Search::SearchService.new(
      query: @query,
      category_slug: @category_slug,
      tag_slug: @tag_slug,
      author_username: @author_username,
      sort_by: @sort_by
    )

    @discussions = @search_service.discussions.page(params[:page]).per(15)
    @matching_users = @search_service.users
    @matching_tags = @search_service.tags
    @matching_categories = @search_service.categories

    @categories = Category.ordered
  end
end

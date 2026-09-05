class CategoriesController < ApplicationController
  def index
    @categories = Category.ordered
  end

  def show
    @category = Category.find_by!(slug: params.expect(:id))
    @sort = params[:sort].presence || "latest"

    discussions_scope = @category.discussions.includes(:user, :tags)

    discussions_scope = case @sort
                        when "trending"
                          discussions_scope.trending
                        when "votes"
                          discussions_scope.most_votes
                        when "replies"
                          discussions_scope.most_replies
                        when "views"
                          discussions_scope.most_viewed
                        else
                          discussions_scope.pinned_first.latest
                        end

    @discussions = discussions_scope.page(params[:page]).per(15)
  end
end

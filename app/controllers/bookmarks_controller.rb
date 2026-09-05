class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def index
    @discussions = current_user.bookmarked_discussions
                               .includes(:user, :category, :tags)
                               .latest
                               .page(params[:page])
                               .per(15)
  end
end

class TagsController < ApplicationController
  def show
    @tag = Tag.find_by!(slug: params.expect(:slug))
    @discussions = @tag.discussions
                       .includes(:user, :category, :tags)
                       .latest
                       .page(params[:page])
                       .per(15)
  end
end

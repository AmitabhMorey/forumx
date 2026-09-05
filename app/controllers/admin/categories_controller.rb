module Admin
  class CategoriesController < BaseController
    before_action :ensure_admin!, except: [:index]
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = Category.ordered
    end

    def new
      @category = Category.new
    end

    def edit; end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: "Category created successfully!"
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category updated successfully!"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @category.discussions.any?
        redirect_to admin_categories_path, alert: "Cannot delete category with discussions. Reassign or remove discussions first."
      else
        @category.destroy!
        redirect_to admin_categories_path, notice: "Category deleted."
      end
    end

    private

    def set_category
      @category = Category.find_by!(slug: params.expect(:id))
    end

    def category_params
      params.expect(category: [:name, :slug, :description, :icon, :color_accent, :position])
    end
  end
end

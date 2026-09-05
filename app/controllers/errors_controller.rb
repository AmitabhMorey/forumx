class ErrorsController < ApplicationController
  layout "application"

  def not_found
    render status: :not_found
  end

  def forbidden
    render status: :forbidden
  end

  def unprocessable_entity
    render status: :unprocessable_content
  end

  def internal_server_error
    render status: :internal_server_error
  end
end

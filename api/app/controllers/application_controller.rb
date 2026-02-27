class ApplicationController < ActionController::Base
  def health
    render json: { status: "ok" }
  end

  def not_found
    render json: { error: "Not Found" }, status: :not_found
  end
end

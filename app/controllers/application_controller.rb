class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  protected

  def render_json_api_success(data)
    render json: data, status: :ok
  end

  def render_json_api_error(data)
    render json: data, status: :unprocessable_entity
  end

  def render_json_api_not_found(data)
    render json: data, status: :not_found
  end
end

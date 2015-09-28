class Api::ApiKeysController < ApiController # rubocop:disable Style/ClassAndModuleChildren
  skip_before_action :verify_authenticity_token
  before_action :authenticated?

  def create
    key = ApiKey.new
    key.user = get_user
    if key.save
      render json: key
    else
      render json: { errors: key.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    key = ApiKey.find(params[:id])
    key.expires_at = 1.day.from_now
    if key.save
      render json: key
    else
      render json: { errors: key.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

class Api::ApiKeysController < ApiController
  skip_before_action :verify_authenticity_token
  before_action :authenticated?

  def create
    key = ApiKey.new
    key.user = User.find(params[:user_id])
    if key.save
      render json: key
    else
      render json: { errors: key.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
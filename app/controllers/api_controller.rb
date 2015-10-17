class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :keyed_open

  def _render_with_renderer_json(json, options)
    serializer = build_json_serializer(json, options)

    if serializer
      super(serializer, options)
    else
      super(json, options)
    end
  end

  private

  def authenticated?
    authenticate_or_request_with_http_basic { |username, password| User.where(username: username, password: password).present? } # rubocop:disable Metrics/LineLength
  end

  def get_login_user # rubocop:disable Style/AccessorMethodName
    user = ''
    authenticate_or_request_with_http_basic do |username, password|
      user = User.where(username: username, password: password).first
    end
    user
  end

  def keyed_open
    time_now = Time.now # rubocop:disable Rails/TimeZone
    authenticate_or_request_with_http_token do |token, _options|
      key = ApiKey.find_by(access_token: token)
      (!key.nil?) && ((key.expires_at - time_now) > 0)
    end
  end

  def get_key_user
    user = ''
    authenticate_or_request_with_http_token do |token, _options|
      key = ApiKey.find_by(access_token: token)
      user = key.user
    end
    user
  end

  def authorization
    key_owner = get_key_user
    controller = params[:controller]
    controller_name = /api\/([a-z]+)/.match(controller)[1]
    if controller_name == 'items'
      list = List.find(params[:list_id])
      unless list.user.id == key_owner.id
        render json: { message: 'you are not the list owner' }, status: :unauthorized
      end
    elsif controller_name == 'lists'
      user = User.find(params[:user_id])
      unless user.id == key_owner.id
        render json: { message: 'you are not the owner of the requested list' }, status: :unauthorized
      end
    else
      render json: { message: 'you are not authorized to this action'}, status: :unauthorized
    end
  end
end

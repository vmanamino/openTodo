class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, :if => :keyed_open

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

  def keyed_open
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end
end

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

  def keyed_open
    time_now = Time.now # rubocop:disable Rails/TimeZone
    authenticate_or_request_with_http_token do |token, _options|
      key = ApiKey.find_by(access_token: token)
      (!key.nil?) && ((key.expires_at - time_now) > 0)
    end
  end
end

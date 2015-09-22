module AuthHelper
  def http_login
    usr = user.username
    pwd = user.password
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(usr, pwd)
  end

  def http_key_auth
    key = api_key.access_token
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(key)
  end

  def user_credentials(usr, pwd)
    ActionController::HttpAuthentication::Basic.encode_credentials(usr, pwd)
  end

  def user_key(key)
    ActionController::HttpAuthentication::Token.encode_credentials(key)
  end
end

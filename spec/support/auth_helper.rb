module AuthHelper
  def http_login
    usr = user.username
    pwd = user.password
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(usr, pwd)
  end
end
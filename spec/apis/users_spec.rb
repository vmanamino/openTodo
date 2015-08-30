require 'rails_helper'

describe Api::UsersController, type: :request do
  let(:user) { create(:user) }
  it 'should render users in json' do
    #user.authentication_token!
    get '/api/users', format: :json
    expect(response).to be(202)
  end
end
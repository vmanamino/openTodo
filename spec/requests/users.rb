require 'rails_helper'
include JsonHelper
include AuthHelper

RSpec.describe Api::UsersController, type: :request do
  let(:controller) { Api::UsersController.new }
  let(:user) { create(:user) }

  describe '#index request' do
    before do
      @users = create_list(:user, 5)
      controller.class.skip_before_filter :authenticated?
    end
    it 'status is 200' do
      get '/api/users'
      expect(response.status).to eq(200)
    end
    it 'response is success' do
      get '/api/users'
      expect(response).to have_http_status(:success)
    end
    it 'responds with serialized users' do
      get '/api/users'
      expect(response_in_json['users'].length).to eq(5)
    end
    it 'serialized users exclude password' do
      get '/api/users'
      check_each_object(response_in_json, 5, 'password', false)
    end
    it 'serialized users include id' do
      get '/api/users'
      check_each_object(response_in_json, 5, 'id', true)
    end
    it 'serialized users include username' do
      get '/api/users'
      check_each_object(response_in_json, 5, 'username', true)
    end
    it 'responds success to authentication with valid username and password' do
      controller.class.before_filter :authenticated?
      user = create(:user)
      credentials = user_credentials(user.username, user.password)
      get '/api/users', nil, { 'HTTP_AUTHORIZATION' => credentials }
      expect(response).to have_http_status(:success)
    end
    it 'responds unauthorized to invalid authentication attempt' do
      controller.class.before_filter :authenticated?
      get '/api/users', nil, { 'HTTP_AUTHORIZATION' => nil }
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe '#create request' do
    before do
      @user = create(:user, username: 'my name', password: 'is special')
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with serialized user' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      expect(response_in_json['user']['username']).to eq('my name')
    end
    it 'serialized user excludes private attribute' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      check_object(response_in_json, 'password', false)
    end
    it 'serialized user includes id' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      check_object(response_in_json, 'id', true)
    end
    it 'serialized user includes username' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      check_object(response_in_json, 'username', true)
    end
    it 'username matches value given' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      expect(response_in_json['user']['username']).to eq(@user.username)
    end
    it 'responds success to authentication with valid username and password' do
      controller.class.before_filter :authenticated?
      user = create(:user)
      credentials = user_credentials(user.username, user.password)
      post '/api/users', { user: { username: @user.username, password: @user.password } }, { 'HTTP_AUTHORIZATION' => credentials }
      expect(response).to have_http_status(:success)
    end
    it 'responds unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      post '/api/users', { user: { username: @user.username, password: @user.password } }, { 'HTTP_AUTHORIZATION' => nil }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with serialized user to authentication with valid username and password' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post '/api/users', { user: { username: @user.username, password: @user.password } }, { 'HTTP_AUTHORIZATION' => credentials }
      expect(response_in_json.length).to eq(1)
    end
    it 'failure responds with appropriate error message for absent password' do
      post '/api/users', user: { username: @user.username, password: ' ' }
      expect(response_in_json['errors'][0]).to eq('Password can\'t be blank')
    end
    it 'failure responds with appropriate error message for absent username' do
      post '/api/users', user: { username: ' ', password: @user.password }
      expect(response_in_json['errors'][0]).to eq('Username can\'t be blank')
    end
  end
end

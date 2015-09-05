require 'rails_helper'
include JsonHelper

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
      json = JSON.parse(response.body)
      expect(json['users'].length).to eq(5)
    end
    it 'serialized users exclude password' do
      get '/api/users'
      json = JSON.parse(response.body)
      check_each_object(json, 5, 'password', false)
    end
    it 'serialized users include id' do
      get '/api/users'
      json = JSON.parse(response.body)
      check_each_object(json, 5, 'id', true)
    end
    it 'serialized users include username' do
      get '/api/users'
      json = JSON.parse(response.body)
      check_each_object(json, 5, 'username', true)
    end
    it 'responds success to authentication with valid username and password' do
      controller.class.before_filter :authenticated?
      user = create(:user)
      credentials = authenticate_user(user.username, user.password)
      get '/api/users', nil, { 'HTTP_AUTHORIZATION' => credentials }
      json = JSON.parse(response.body)
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
    it 'status is 200' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      expect(response.status).to eq(200)
    end
    it 'response is success' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      expect(response).to have_http_status(:success)
    end
    it 'responds with serialized user' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      json = JSON.parse(response.body)
      expect(json['user']['username']).to eq('my name')
    end
    it 'serialized user excludes private attribute' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      json = JSON.parse(response.body)
      check_object(json, 'password', false)
    end
    it 'serialized user includes id' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      json = JSON.parse(response.body)
      check_object(json, 'id', true)
    end
    it 'serialized user includes username' do
      post '/api/users', user: { username: @user.username, password: @user.password }
      json = JSON.parse(response.body)
      check_object(json, 'username', true)
    end
    it 'responds success to authentication with valid username and password' do
      controller.class.before_filter :authenticated?
      user = create(:user)
      credentials = authenticate_user(user.username, user.password)
      post '/api/users', user: { username: @user.username, password: @user.password }, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:success)
    end
  end

  def authenticate_user(usr, pwd)
    ActionController::HttpAuthentication::Basic.encode_credentials(usr, pwd)
  end
end
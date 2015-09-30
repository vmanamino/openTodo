require 'rails_helper'
include JsonHelper
include AuthHelper

RSpec.describe Api::UsersController, type: :request do
  let(:controller) { Api::UsersController.new }
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:key) { user_key(api_key.access_token) }
  describe '#index request' do
    before do
      @users = create_list(:user, 5)
    end
    it 'status is 200' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      expect(response.status).to eq(200)
    end
    it 'response is success' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:success)
    end
    it 'responds with serialized users' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['users'].length).to eq(6) # 1 extra for the user needed to create api_key
    end
    it 'serialized users exclude password' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'password', false)
    end
    it 'serialized users include id' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'id', true)
    end
    it 'serialized users include username' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'username', true)
    end
    it 'responds unauthorized to invalid authentication attempt' do
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe '#create request' do
    it 'responds with serialized user' do
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response_in_json['user']['username']).to eq('my name')
    end
    it 'serialized user excludes private attribute' do
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      check_object(response_in_json, 'password', false)
    end
    it 'serialized user includes id' do
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      check_object(response_in_json, 'id', true)
    end
    it 'serialized user includes username' do
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      check_object(response_in_json, 'username', true)
    end
    it 'username matches value given' do
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response_in_json['user']['username']).to eq('my name')
    end
    it 'responds unauthorized to unauthenticated user' do
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe '#destroy' do
    before do
      @user_destroy = create(:user)
    end
    it 'responds with no_content' do
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with code 204' do
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      expect(response.status).to eq(204)
    end
    it 'responds with unauthorized to unauthenticated user' do
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with code 401 to unauthenticated user' do
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response.status).to eq(401)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'http error status not_found' do
      delete '/api/users/100', nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:not_found)
    end
    it 'error code 404' do
      delete '/api/users/100', nil, 'HTTP_AUTHORIZATION' => key
      expect(response.status).to eq(404)
    end
  end
end

require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ApiKeysController, type: :request do
  let(:user) { create(:user) }
  let(:list) { create(:list, user: user) }
  let(:api_key_old) { create(:api_key, expires_at: 1.day.ago) }
  let(:credentials) { user_credentials(user.username, user.password) }
  describe '#create request' do
    it 'responds with object serialized in json' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      expect(response_in_json.length).to eq(1)
    end
    it 'serialized object includes access_token' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      check_object(response_in_json, 'api_key', 'access_token', true)
    end
    it 'serialized object includes expires_at' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      check_object(response_in_json, 'api_key', 'expires_at', true)
    end
    it 'serialized object access_token matches actual object access_token' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      api_key = ApiKey.find(1)
      expect(response_in_json['api_key']['access_token']).to eq(api_key.access_token)
    end
    it 'serialized api key belongs to authenticated user' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      api_key = ApiKey.find(1)
      expect(api_key.user).to eq(user)
    end
    it 'responds with success' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:success)
    end
    it 'access_token authenticates user to request/create list' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      api_key = ApiKey.find(1)
      key = user_key(api_key.access_token)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['list']).not_to be nil
    end
    it 'access_token authenticates user to request/create item' do
      post '/api/api_keys', nil, 'HTTP_AUTHORIZATION' => credentials
      api_key = ApiKey.find(1)
      key = user_key(api_key.access_token)
      post "/api/lists/#{list.id}/items", { item: { name: 'my item', done: false } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['item']).not_to be nil
    end
  end
  describe '#update request' do
    it 'expired/invalid key unauthorized to create list' do
      key = user_key(api_key_old.access_token)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'updated key authorized to create list' do
      patch "/api/api_keys/#{api_key_old.id}", nil, 'HTTP_AUTHORIZATION' => credentials
      api_key_old.reload
      key = user_key(api_key_old.access_token)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:success)
    end
  end
end

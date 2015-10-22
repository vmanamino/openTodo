require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ApiKeysController, type: :controller do
  let(:user) { create(:user) }
  let(:credentials) { user_credentials(user.username, user.password) }
  let(:api_key) { create(:api_key, expires_at: 1.day.ago) }
  describe '#create' do
    it 'denied to unauthenticated user' do
      post :create
      expect(response).to have_http_status(:unauthorized)
    end
    it 'permitted to authenticated user' do
      http_login
      post :create
      expect(response).to have_http_status(:success)
    end
    it 'new item in JSON' do
      http_login
      post :create
      expect(response_in_json['api_key']).not_to be nil
    end
    it 'includes access_token' do
      http_login
      post :create
      check_object(response_in_json, 'api_key', 'access_token', true)
    end
    it 'includes expires_at' do
      http_login
      post :create
      check_object(response_in_json, 'api_key', 'expires_at', true)
    end
  end
  describe '#update' do
    it 'expired key has no time left' do
      expect(api_key.expires_at - Time.now).to be < 0 # rubocop:disable Rails/TimeZone
    end
    it 'updated key has one day' do
      http_login
      patch :update, id: api_key.id
      api_key.reload
      expect(((api_key.expires_at - Time.now) / 1.day).round).to eq 1 # rubocop:disable Rails/TimeZone
    end
  end
end

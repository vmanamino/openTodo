require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ListsController, type: :controller do
  let(:user) { create(:user) }
  describe '#create' do
    it 'denied to unauthenticated user' do
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'public' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'permitted to authenticated user' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'public' }
      expect(response).to have_http_status(:success)
    end
    it 'new list in JSON' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json.length).to eq(1)
    end
    it 'new list has default permissions \'public\'' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('public')
    end
    it 'includes id' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'includes name' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'name', true)
    end
    it 'includes permissions' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'permissions', true)
    end
    it 'includes user id' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'user_id', true)
    end
    it 'user_id belongs to user' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['user_id']).to eq(user.id)
    end
    it 'permissions automatically set to public' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('public')
    end
    it 'enter private permissions' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'private' }
      expect(response_in_json['list']['permissions']).to eq('private')
    end
    it 'failure responds with appropriate error message for absent name' do
      http_login
      post :create, user_id: user.id, list: { name: ' ' }
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
end
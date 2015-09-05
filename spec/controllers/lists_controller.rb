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
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
    end
    it 'new list has default permissions \'public\'' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      json = JSON.parse(response.body)
      expect(json['list']['permissions']).to eq('public')
    end
    it 'includes id' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      json = JSON.parse(response.body)
      check_object(json, 'list', 'id', true)
    end
    it 'includes name' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      json = JSON.parse(response.body)
      check_object(json, 'list', 'name', true)
    end
    it 'includes permissions' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      json = JSON.parse(response.body)
      check_object(json, 'list', 'permissions', true)
    end
    it 'includes user id' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      json = JSON.parse(response.body)
      check_object(json, 'list', 'user_id', true)
    end
  end
end
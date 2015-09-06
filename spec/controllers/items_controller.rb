require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:list) { create(:list) }
  describe '#create' do
    it 'denied to unauthenticated user' do
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'permitted to authenticated user' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response).to have_http_status(:success)
    end
    it 'new item in JSON' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response_in_json.length).to eq(1)
    end
    it 'includes id' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'id', true)
    end
    it 'includes name' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'name', true)
    end
    it 'includes list_id' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'name', true)
    end
    it 'name matches value given' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response_in_json['item']['name']).to eq('get it done')
    end
    it 'list_id belongs to list' do
      http_login
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response_in_json['item']['list_id']).to eq(list.id)
    end
    it 'failure responds with appropriate message for absent name' do
      http_login
      post :create, list_id: list.id, item: { name: ' ' }
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
end
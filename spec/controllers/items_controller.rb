require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list) }
  describe '#index' do
    before do
      @items = create_list(:item, 5)
    end
    it 'responds with success to key authenticated user' do
      http_key_auth
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with items in serialized json' do
      http_key_auth
      get :index
      expect(response_in_json['items'].length).to eq(5)
    end
    it 'serialized items include id' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'items', 'id', true)
    end
    it 'serialized items include name' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'items', 'name', true)
    end
    it 'serialized items include done' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'items', 'done', true)
    end
    it 'serialized items include list reference' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'items', 'list_id', true)
    end
  end
  describe '#create' do
    it 'denied to unauthenticated user' do
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'denied to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'permitted to authenticated user' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response).to have_http_status(:success)
    end
    it 'new item in JSON' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'new thing to do' }
      expect(response_in_json['item']['name']).to eq('new thing to do')
    end
    it 'includes id' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'id', true)
    end
    it 'includes name' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'name', true)
    end
    it 'includes done' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'done', true)
    end
    it 'includes list_id' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      check_object(response_in_json, 'item', 'name', true)
    end
    it 'name matches value given' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response_in_json['item']['name']).to eq('get it done')
    end
    it 'list_id belongs to list' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response_in_json['item']['list_id']).to eq(list.id)
    end
    it 'done is false by default' do
      http_key_auth
      post :create, list_id: list.id, item: { name: 'get it done' }
      expect(response_in_json['item']['done']).to eq(false)
    end
    it 'failure responds with appropriate message for absent name' do
      http_key_auth
      post :create, list_id: list.id, item: { name: ' ' }
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
  describe '#update' do
    before do
      @item_update = create(:item, list_id: list.id)
    end
    it 'responds with status 202' do
      http_key_auth
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: true }
      expect(response.status).to eq(200)
    end
    it 'denies unauthenticated user' do
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: true }
      expect(response.status).to eq(401)
    end
    it 'denies expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: true }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'saves attributes' do
      http_key_auth
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: true }
      updated_item = Item.find(@item_update.id)
      expect(updated_item.name).to eq('my finished item')
      expect(updated_item.done).to be true
    end
    it 'raises exception status' do
      http_key_auth
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: nil }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'responds with 422 code' do
      http_key_auth
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: nil }
      expect(response.status).to eq(422)
    end
    it 'responds with appropriate error message' do
      http_key_auth
      patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: nil }
      expect(response_in_json['errors'][0]).to eq('Done is not included in the list')
    end
  end
end

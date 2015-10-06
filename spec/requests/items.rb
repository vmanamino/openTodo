require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ItemsController, type: :request do
  let(:list) { create(:list) }
  let(:user) { create(:user) }
  let(:controller) { Api::ItemsController.new }
  let(:api_key) { create(:api_key, user: user) }
  let(:key) { user_key(api_key.access_token) }
  describe '#index request' do
    before do
      @list_one_user = create(:list, user: user)
      @items_list_one_user = create_list(:item, 5, list: @list_one_user)
      @list_two_user = create(:list, user: user)
      @items_list_two_user = create_list(:item, 5, list: @list_two_user) # total 10 items in response
      @list_one_other = create(:list)
      @items_list_one_other = create_list(:item, 5, list: @list_one_other)
      @list_two_other = create(:list)
      @items_list_two_other = create_list(:item, 5, list: @list_two_other) # total 20 items in db
    end
    it 'responds with success to key authenticated user' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with all items in serialized json' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['items'].length).to eq(10)
    end
    it 'all items belong to key user' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      object_owner(response_in_json, 'Item', 'items', user)
    end
    it 'number of items in response reflect ownership' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      items_all = Item.all
      expect(items_all.length).to eq(20)
      expect(response_in_json['items'].length).to eq(10)
    end
    it 'serialized items include id' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'items', 'id', true)
    end
    it 'serialized items include name' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'items', 'name', true)
    end
    it 'serialized json includes done' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'items', 'done', true)
    end
    it 'serialized json includes list reference' do
      get "/api/items", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'items', 'list_id', true)
    end
  end
  describe '#create request' do
    it 'responds with object serialized in JSON' do
      post "/api/lists/#{list.id}/items", { item: { name: 'my item' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['item']['name']).to eq('my item')
    end
    it 'serialized object includes id' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'item', 'id', true)
    end
    it 'serialized object includes name' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'item', 'name', true)
    end
    it 'serialized object includes list_id' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'item', 'list_id', true)
    end
    it 'serialized object includes done' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done on time' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'item', 'done', true)
    end
    it 'name matches name entered' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done on time' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['item']['name']).to eq('get done on time')
    end
    it 'list_id belongs to list in params' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['item']['list_id']).to eq(list.id)
    end
    it 'done is set to false by default' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['item']['done']).to eq(false)
    end
    it 'one item is created with id value' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get done' } }, 'HTTP_AUTHORIZATION' => key
      item = Item.all
      expect(item.length).to eq(1)
      expect(item[0][:id]).to_not be nil
    end
    it 'responds with success to authenticated user' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:success)
    end
    it 'response unauthorized to unauthenticated user' do
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token) # rubocop:disable Lint/UselessAssignment
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'failure responds with appropriate message for absent name' do
      post "/api/lists/#{list.id}/items", { item: { name: ' ' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
  describe '#update request' do
    before do
      @item_update = create(:item, list_id: list.id)
    end
    it 'responds with success' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:success)
    end
    it 'saves attributes' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response_in_json['item']['name']).to eq('my finished item')
      expect(response_in_json['item']['done']).to eq(true)
    end
    it 'raises exception status' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: nil } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response.status).to eq(422)
    end
    it 'produces appropriate error message' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: nil } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response_in_json['errors'][0]).to eq('Done is not included in the list')
    end
    it 'responds with success to authenticated user' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' =>  nil # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

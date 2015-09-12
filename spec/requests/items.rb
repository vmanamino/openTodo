require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ItemsController, type: :request do
  let(:list) { create(:list) }
  let(:user) { create(:user) }
  let(:controller) { Api::ItemsController.new }
  describe '#create request' do
    before do
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with object serialized in JSON' do
      post "/api/lists/#{list.id}/items", item: { name: 'my item' }
      expect(response_in_json.length).to eq(1)
    end
    it 'serialized object includes id' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done' }
      check_object(response_in_json, 'item', 'id', true)
    end
    it 'serialized object includes name' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done' }
      check_object(response_in_json, 'item', 'name', true)
    end
    it 'serialized object includes list_id' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done' }
      check_object(response_in_json, 'item', 'list_id', true)
    end
    it 'serialized object includes done' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done on time' }
      check_object(response_in_json, 'item', 'done', true)
    end
    it 'name matches name entered' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done on time' }
      expect(response_in_json['item']['name']).to eq('get done on time')
    end
    it 'list_id belongs to list in params' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done' }
      expect(response_in_json['item']['list_id']).to eq(list.id)
    end
    it 'done is set to false by default' do
      post "/api/lists/#{list.id}/items", item: { name: 'get it done' }
      expect(response_in_json['item']['done']).to eq(false)
    end
    it 'one item is created with id value' do
      post "/api/lists/#{list.id}/items", item: { name: 'get done' }
      item = Item.all
      expect(item.length).to eq(1)
      expect(item[0][:id]).to_not be nil
    end
    it 'responds with success to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:success)
    end
    it 'response unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with serialized item object to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/lists/#{list.id}/items", { item: { name: 'get it done' } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response_in_json.length).not_to be nil
    end
    it 'failure responds with appropriate message for absent name' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/lists/#{list.id}/items", { item: { name: ' ' } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
  describe '#update request' do
    before do
      @item_update = create(:item, list_id: list.id)
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with success' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", item: { name: 'my finished item', done: true }
      expect(response).to have_http_status(:success)
    end
    it 'saves attributes' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", item: { name: 'my finished item', done: true }
      expect(response_in_json['item']['name']).to eq('my finished item')
      expect(response_in_json['item']['done']).to eq(true)
    end
    it 'raises exception status' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", item: { name: 'my finished item', done: nil }
      expect(response.status).to eq(422)
    end
    it 'produces appropriate error message' do
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", item: { name: 'my finished item', done: nil }
      expect(response_in_json['errors'][0]).to eq('Done is not included in the list')
    end
    it 'responds with success to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' =>  nil
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

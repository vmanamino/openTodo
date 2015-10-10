require 'rails_helper'
include JsonHelper
include AuthHelper

RSpec.describe Api::ListsController, type: :request do
  let(:controller) { Api::ListsController.new }
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:key) { user_key(api_key.access_token) }
  describe '#index request' do
    before do
      @lists = create_list(:list, 5) # 5 lists
      @lists_open = create_list(:list, 5, permissions: 'open') # + 5 lists = 10
      @lists_private = create_list(:list, 5, permissions: 'private') # + 5 lists = 15 lists WILL NOT appear in request responses
      @key_user = api_key.user
      @lists_user = create_list(:list, 5, user: @key_user) # 5 lists
      @lists_user_private = create_list(:list, 5, user: @key_user, permissions: 'private') # + 5 = 10 lists WILL appear in request responses
    end
    it 'responds with success to key authenticated user' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'lists owned by key user are returned' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      object_owner(response_in_json, 'List', 'lists', @key_user)
    end
    it 'lists owned by key user are 10' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['lists'].length).to eq(10)
    end
    it 'lists created in total are 25' do
      lists_all = List.all
      expect(lists_all.length).to eq(25)
    end
    it 'permitted lists include id' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'lists', 'id', true)
    end
    it 'permitted lists include name' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'lists', 'name', true)
    end
    it 'permitted lists include user_id' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' => key
      check_each_object(response_in_json, 'lists', 'user_id', true)
    end
    it 'permitted lists include permissions' do
      get "/api/lists", nil, 'HTTP_AUTHORIZATION' =>  key
      check_each_object(response_in_json, 'lists', 'permissions', true)
    end
  end
  describe '#create request' do
    it 'responds with a list object serialized in JSON' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my new list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['list']['name']).to eq('my new list')
    end
    it 'serialized list includes id' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'serialized list includes name' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'serialized list includes user_id' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      check_object(response_in_json, 'list', 'user_id', true)
    end
    it 'list user is key user' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      key_user = api_key.user
      expect(response_in_json['list']['user_id']).to eq(key_user.id)
    end
    it 'params user is list user' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['list']['user_id']).to eq(user.id)
    end
    it 'responds with unprocessable entity when key user not user in params' do
      key_other = create(:api_key)
      key = user_key(key_other.access_token)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'permissions automatically set to viewable' do
      post "/api/users/#{user.id}/lists", { list: {  name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['list']['permissions']).to eq('viewable')
    end
    it 'enter private permissions' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response_in_json['list']['permissions']).to eq('private')
    end
    it 'responds with sucess to authenticated user' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'failure responds with appropriate error message for absent name' do
      post "/api/users/#{user.id}/lists", { list: { name: ' ' } }, 'HTTP_AUTHORIZATION' => key
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
  describe '#update request' do
    before do
      @list_update = create(:list, user_id: user.id)
    end
    it 'responds with status 200' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(200)
    end
    it 'saves attributes' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      updated_list = List.find(@list_update.id)
      expect(updated_list.name).to eq('my new list')
      expect(updated_list.permissions).to eq('private')
    end
    it 'raises exception status' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'update not granted' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(422)
    end
    it 'appropriate error message' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'update not granted' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response_in_json['errors'][0]).to eq('Permissions is not included in the list')
    end
    it 'responds with success to authenticated user' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => nil # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with ActiveRecord error to user other than list user' do
      key_other = create(:api_key)
      key = user_key(key_other.access_token)
      expect { patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private'} }, 'HTTP_AUTHORIZATION' => key }.to raise_exception(ActiveRecord::RecordNotFound) # rubocop:disable Metrics/LineLength
    end
  end
  describe '#destroy request' do
    before do
      @list_destroy = create(:list, user_id: user.id)
      @items = create_list(:item, 5, list_id: @list_destroy.id)
    end
    it 'responds with no_content' do
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with code 204' do
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      expect(response.status).to eq(204)
    end
    it 'responds with status code 401 to unauthenticated user' do
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response.status).to eq(401)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      key = user_key(api_key.access_token)
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      expect(response).to have_http_status(:unauthorized)
    end
    it 'raises exception status not_found for missing list' do
      expect { delete "/api/users/#{user.id}/lists/100", nil, 'HTTP_AUTHORIZATION' => key }.to raise_exception(ActiveRecord::RecordNotFound)
    end
    it 'raises ActiveRecord error to user other than list user' do
      key_other = create(:api_key)
      key = user_key(key_other.access_token)
      expect{ delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key }.to raise_exception(ActiveRecord::RecordNotFound)
    end
    it 'destroys item dependents' do
      items = Item.all
      expect(items.length).to eq(5)
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
      items.reload
      expect(items.length).to eq(0)
    end
  end
end

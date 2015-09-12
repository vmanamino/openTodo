require 'rails_helper'
include JsonHelper
include AuthHelper

RSpec.describe Api::ListsController, type: :request do
  let(:controller) { Api::ListsController.new }
  let(:user) { create(:user) }
  describe '#create request' do
    before do
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with a list object serialized in JSON' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      expect(response_in_json.length).to eq(1)
    end
    it 'serialized list includes id' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'serialized list includes name' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'serialized list includes user_id' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      check_object(response_in_json, 'list', 'user_id', true)
    end
    it 'user_id belongs to user' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      expect(response_in_json['list']['user_id']).to eq(user.id)
    end
    it 'permissions automatically set to public' do
      post "/api/users/#{user.id}/lists", list: {  name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('public')
    end
    it 'enter private permissions' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list', permissions: 'private' }
      expect(response_in_json['list']['permissions']).to eq('private')
    end
    it 'responds with sucess to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => nil
    end
    it 'responds with serialized list object to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response_in_json.length).to eq(1)
    end
    it 'failure responds with appropriate error message for absent name' do
      post "/api/users/#{user.id}/lists", list: { name: ' ' }
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
  describe '#update request' do
    before do
      @list_update = create(:list, user_id: user.id)
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with status 200' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", list: { name: 'my new list', permissions: 'private' }
      expect(response).to have_http_status(200)
    end
    it 'saves attributes' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", list: { name: "my new list", permissions: 'private' }
      updated_list = List.find(@list_update.id)
      expect(updated_list.name).to eq('my new list')
      expect(updated_list.permissions).to eq('private')
    end
    it 'raises exception status' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", list: { name: 'my new list', permissions: 'update not granted' }
      expect(response).to have_http_status(422)
    end
    it 'appropriate error message' do
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", list: { name: 'my new list', permissions: 'update not granted' }
      expect(response_in_json['errors'][0]).to eq('Permissions is not included in the list')
    end
    it 'responds with success to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private'} }, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe '#destroy request' do
    before do
      @list_destroy = create(:list, user_id: user.id)
      @items = create_list(:item, 5, list_id: @list_destroy.id)
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with no_content' do
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}"
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with code 204' do
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}"
      expect(response.status).to eq(204)
    end
    it 'responds with no_content to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => credentials
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with code 204 to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => credentials
      expect(response.status).to eq(204)
    end
    it 'responds with unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with status code 401 to unauthenticated user' do
      controller.class.before_filter :authenticated?
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => nil
      expect(response.status).to eq(401)
    end
    it 'raises exception status not_found' do
      delete "/api/users/#{user.id}/lists/100"
      expect(response).to have_http_status(:not_found)
    end
    it 'raises code 404 for exception' do
      delete "/api/users/#{user.id}/lists/100"
      expect(response.status).to eq(404)
    end
    it 'destroys item dependents' do
      items = Item.all
      expect(items.length).to eq(5)
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}"
      items.reload
      expect(items.length).to eq(0)
    end
  end
end

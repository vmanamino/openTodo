require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ListsController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  describe '#index' do
    before do
      @lists = create_list(:list, 5)
      @lists_user = create_list(:list, 5, user: api_key.user) # total 10 lists, only 5 in response
    end
    it 'responds with success to authenticated user' do
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
    it 'responds with lists serialized in json' do
      http_key_auth
      get :index
      expect(response_in_json['lists'].length).to eq(5)
    end
    it 'lists returned belong to key user' do
      http_key_auth
      get :index
      object_owner(response_in_json, 'List', 'lists', api_key.user)
    end
    it 'number of lists in response reflects ownership' do
      http_key_auth
      get :index
      lists_all = List.all
      expect(lists_all.length).to eq(10)
      expect(response_in_json['lists'].length).to eq(5)
    end
    it 'serialized json lists include id' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'lists', 'id', true)
    end
    it 'serialized json lists include name' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'lists', 'id', true)
    end
    it 'serialized json lists include permissions' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'lists', 'id', true)
    end
    it 'serialized json lists include user_id' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'lists', 'user_id', true)
    end
  end
  describe '#create' do
    it 'denied to unauthenticated user' do
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'viewable' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'denied to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'viewable' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'permitted to authenticated user' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'viewable' }
      expect(response).to have_http_status(:success)
    end
    it 'new list in JSON' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my new list' }
      expect(response_in_json['list']['name']).to eq('my new list')
    end
    it 'new list has default permissions \'viewable\'' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('viewable')
    end
    it 'includes id' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'includes name' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'name', true)
    end
    it 'includes permissions' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'permissions', true)
    end
    it 'includes user id' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      check_object(response_in_json, 'list', 'user_id', true)
    end
    it 'user_id belongs to user' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['user_id']).to eq(user.id)
    end
    it 'permissions automatically set to \'viewable\'' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('viewable')
    end
    it 'enter private permissions' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'private' }
      expect(response_in_json['list']['permissions']).to eq('private')
    end
    it 'failure responds with appropriate error message for absent name' do
      http_key_auth
      post :create, user_id: user.id, list: { name: ' ' }
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
    it 'list user is key user' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['user_id']).to eq(api_key.user.id)
    end
    it 'params user is list user' do
      http_key_auth
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['user_id']).to eq(user.id)
    end
    it 'responds with unauthorized when key user not user in params' do
      user_other = create(:user)
      http_key_auth
      post :create, user_id: user_other.id, list: { name: 'my list'}
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with appropriate message when key user not user in params' do
      user_other = create(:user)
      http_key_auth
      post :create, user_id: user_other.id, list: { name: 'my list' }
      expect(response_in_json['message']).to eq('you are not the owner of the requested list')
    end
  end
  describe '#update' do
    before do
      @list_update = create(:list, user_id: user.id)
    end
    it 'it responds with status 200' do
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
      expect(response.status).to eq(200)
    end
    it 'denies unauthenticated user' do
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
      expect(response.status).to eq(401)
    end
    it 'saves attributes' do
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
      updated_list = List.find(@list_update.id)
      expect(updated_list.name).to eq('new and improved')
      expect(updated_list.permissions).to eq('private')
    end
    it 'raises exception status' do
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'responds with 422 code' do
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
      expect(response.status).to eq(422)
    end
    it 'appropriate error message' do
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
      expect(response_in_json['errors'][0]).to eq('Permissions is not included in the list')
    end
    it 'denied to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with unauthorized when key user is not list user' do
      other_user = create(:user)
      api_key.user = other_user
      api_key.save
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private'}
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with appropriate message when key user is not list user' do
      other_user = create(:user)
      api_key.user = other_user
      api_key.save
      http_key_auth
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private'}
      expect(response_in_json['message']).to eq('you are not the owner of the requested list')
    end
  end
  describe '#destroy' do
    before do
      @list_destroy = create(:list, user_id: user.id)
      @items = create_list(:item, 5, list_id: @list_destroy.id)
    end
    it 'responds with status no_content' do
      http_key_auth
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with status code 204' do
      http_key_auth
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response.status).to eq(204)
    end
    it 'responds with unauthorized to unauthenticated user' do
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with status code 401 to unauthenticated user' do
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response.status).to eq(401)
    end
    it 'responds with unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response).to have_http_status(:unauthorized)
    end
    it 'raises exception status not found' do
      http_key_auth
      expect { delete :destroy, user_id: user.id, id: 100 }.to raise_exception(ActiveRecord::RecordNotFound)
    end
    it 'responds with unauthorized when key user is not list user' do
      user_other = create(:user)
      api_key.user = user_other
      api_key.save
      http_key_auth
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with appopriate message when key user is not list user' do
      user_other = create(:user)
      api_key.user = user_other
      api_key.save
      http_key_auth
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response_in_json['message']).to eq('you are not the owner of the requested list')
    end
    it 'destroys item dependents' do
      items = Item.all
      expect(items.length).to eq(5)
      http_key_auth
      delete :destroy, user_id: user.id, id: @list_destroy.id
      items.reload
      expect(items.length).to eq(0)
    end
  end
end

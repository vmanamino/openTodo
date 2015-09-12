require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::ListsController, type: :controller do
  let(:user) { create(:user) }
  describe '#create' do
    it 'denied to unauthenticated user' do
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'viewable' }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'permitted to authenticated user' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list', permissions: 'viewable' }
      expect(response).to have_http_status(:success)
    end
    it 'new list in JSON' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json.length).to eq(1)
    end
    it 'new list has default permissions \'viewable\'' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('viewable')
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
    it 'permissions automatically set to \'viewable\'' do
      http_login
      post :create, user_id: user.id, list: { name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('viewable')
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
  describe '#update' do
    before do
      @list_update = create(:list, user_id: user.id)
    end
    it 'it responds with status 200' do
      http_login
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
      expect(response.status).to eq(200)
    end
    it 'denies unauthenticated user' do
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
      expect(response.status).to eq(401)
    end
    it 'saves attributes' do
      http_login
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
      updated_list = List.find(@list_update.id)
      expect(updated_list.name).to eq('new and improved')
      expect(updated_list.permissions).to eq('private')
    end
    it 'raises exception status' do
      http_login
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'responds with 422 code' do
      http_login
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' }
      expect(response.status).to eq(422)
    end
    it 'appropriate error message' do
      http_login
      patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' }
      expect(response_in_json['errors'][0]).to eq('Permissions is not included in the list')
    end
  end
  describe '#destroy' do
    before do
      @list_destroy = create(:list, user_id: user.id)
      @items = create_list(:item, 5, list_id: @list_destroy.id)
    end
    it 'responds with status no_content' do
      http_login
      delete :destroy, user_id: user.id, id: @list_destroy.id
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with status code 204' do
      http_login
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
    it 'raises exception status not found' do
      http_login
      delete :destroy, user_id: user.id, id: 100
      expect(response).to have_http_status(:not_found)
    end
    it 'raises not found code 404' do
      http_login
      delete :destroy, user_id: user.id, id: 100
      expect(response.status).to eq(404)
    end
    it 'destroys item dependents' do
      items = Item.all
      expect(items.length).to eq(5)
      http_login
      delete :destroy, user_id: user.id, id: @list_destroy.id
      items.reload
      expect(items.length).to eq(0)
    end
  end
end

require 'rails_helper'
include AuthHelper
include JsonHelper
include ExpiredKey

RSpec.describe Api::ListsController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  describe '#index' do
    before do
      @lists = create_list(:list, 5)
      @lists_user = create_list(:list, 5, user: api_key.user) # total 10 lists, only 5 in response
    end
    context 'active key' do
      before do
        http_key_auth
      end
      it_behaves_like 'index with active valid key'
      it 'responds with lists serialized in json' do
        get :index
        expect(response_in_json['lists'].length).to eq(5)
      end
      it 'lists returned belong to key user' do
        get :index
        object_owner(response_in_json, 'List', 'lists', api_key.user)
      end
      it 'number of lists in response reflects ownership' do
        get :index
        lists_all = List.all
        expect(lists_all.length).to eq(10)
        expect(response_in_json['lists'].length).to eq(5)
      end
      it 'serialized json lists include id' do
        get :index
        check_each_object(response_in_json, 'lists', 'id', true)
      end
      it 'serialized json lists include name' do
        get :index
        check_each_object(response_in_json, 'lists', 'id', true)
      end
      it 'serialized json lists include permissions' do
        get :index
        check_each_object(response_in_json, 'lists', 'id', true)
      end
      it 'serialized json lists include user_id' do
        get :index
        check_each_object(response_in_json, 'lists', 'user_id', true)
      end
    end
    context 'user with no key' do
      it_behaves_like 'index unauthorized'
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'index with expired key'
    end
  end
  describe '#create' do
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with active valid key', 'list', { name: 'my shared example list', permissions: 'viewable' }
      it 'new list in JSON' do
        post :create, user_id: user.id, list: { name: 'my new list' }
        expect(response_in_json['list']['name']).to eq('my new list')
      end
      it 'new list has default permissions \'viewable\'' do
        post :create, user_id: user.id, list: { name: 'my list' }
        expect(response_in_json['list']['permissions']).to eq('viewable')
      end
      it 'includes id' do
        post :create, user_id: user.id, list: { name: 'my list' }
        check_object(response_in_json, 'list', 'id', true)
      end
      it 'includes name' do
        post :create, user_id: user.id, list: { name: 'my list' }
        check_object(response_in_json, 'list', 'name', true)
      end
      it 'includes permissions' do
        post :create, user_id: user.id, list: { name: 'my list' }
        check_object(response_in_json, 'list', 'permissions', true)
      end
      it 'includes user id' do
        post :create, user_id: user.id, list: { name: 'my list' }
        check_object(response_in_json, 'list', 'user_id', true)
      end
      it 'user_id belongs to user' do
        post :create, user_id: user.id, list: { name: 'my list' }
        expect(response_in_json['list']['user_id']).to eq(user.id)
      end
      it 'permissions automatically set to \'viewable\'' do
        post :create, user_id: user.id, list: { name: 'my list' }
        expect(response_in_json['list']['permissions']).to eq('viewable')
      end
      it 'enter private permissions' do
        post :create, user_id: user.id, list: { name: 'my list', permissions: 'private' }
        expect(response_in_json['list']['permissions']).to eq('private')
      end
      it 'failure responds with appropriate error message for absent name' do
        post :create, user_id: user.id, list: { name: ' ' }
        expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
      end
      it 'list user is key user' do
        post :create, user_id: user.id, list: { name: 'my list' }
        expect(response_in_json['list']['user_id']).to eq(api_key.user.id)
      end
      it 'params user is list user' do
        post :create, user_id: user.id, list: { name: 'my list' }
        expect(response_in_json['list']['user_id']).to eq(user.id)
      end
      it 'responds with unauthorized when key user not user in params' do
        user_other = create(:user)
        post :create, user_id: user_other.id, list: { name: 'my list'}
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'user with no key' do
      it_behaves_like 'create unauthorized', 'list', { name: 'my list', permissions: 'viewable' }
    end
    context 'expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with expired key', 'list', { name: 'my shared example list', permissions: 'viewable' }
    end
    context 'user with wrong key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with the wrong key', 'list', { name: 'my shared example list', permissions: 'viewable' }
      it_behaves_like 'create with the wrong key message', 'list', { name: 'my shared example list', permissions: 'viewable' }, 'you are not the owner of the requested list' # rubocop:disable Metrics/LineLength
    end
  end
  describe '#update' do
    before do
      @list_update = create(:list, user_id: user.id)
    end
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'update with active valid key', 'list', { name: 'new and improved', permissions: 'private' }
      it 'saves attributes' do
        patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'private' }
        updated_list = List.find(@list_update.id)
        expect(updated_list.name).to eq('new and improved')
        expect(updated_list.permissions).to eq('private')
      end
      context 'invalid permissions' do
        it 'raises exception status' do
          patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'responds with 422 code' do
          patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
          expect(response.status).to eq(422)
        end
        it 'appropriate error message' do
          patch :update, user_id: user.id, id: @list_update.id, list: { name: 'new and improved', permissions: 'cannot be updated' } # rubocop:disable Metrics/LineLength
          expect(response_in_json['errors'][0]).to eq('Permissions is not included in the list')
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'update unauthorized', 'list', { name: 'new and improved', permissions: 'private' }
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'update with expired key', 'list', { name: 'new and improved', permissions: 'private' }
    end
    context 'user with wrong key' do
      before do
        http_key_auth
      end
      it_behaves_like 'update with the wrong key', 'list', { name: 'new and improved', permissions: 'private' }
      it_behaves_like 'update with the wrong key message', 'list', { name: 'new and improved', permissions: 'private' }, 'you are not the owner of the requested list'
    end
  end
  describe '#destroy' do
    before do
      @list_destroy = create(:list, user_id: user.id)
      @items = create_list(:item, 5, list_id: @list_destroy.id)
    end
    context 'user with active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with active valid key', 'list'
      context 'list not found' do
        it 'raises exception status not found' do
          expect { delete :destroy, user_id: user.id, id: 100 }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
      context 'item dependents' do
         it 'destroys item dependents' do
          items = Item.all
          expect(items.length).to eq(5)
          delete :destroy, user_id: user.id, id: @list_destroy.id
          items.reload
          expect(items.length).to eq(0)
        end
      end
    end
    context 'user without key' do
      it 'responds with unauthorized to unauthenticated user' do
        delete :destroy, user_id: user.id, id: @list_destroy.id
        expect(response).to have_http_status(:unauthorized)
      end
      it 'responds with status code 401 to unauthenticated user' do
        delete :destroy, user_id: user.id, id: @list_destroy.id
        expect(response.status).to eq(401)
      end
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with expired key', 'list'
    end
    context 'user with wrong key' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with the wrong key', 'list'
      it_behaves_like 'destroy with the wrong key message', 'list', 'you are not the owner of the requested list'
    end
  end
end

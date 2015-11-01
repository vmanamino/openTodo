require 'rails_helper'

include JsonHelper
include AuthHelper
include ExpiredKey

RSpec.describe Api::ListsController, type: :request do
  let(:controller) { Api::ListsController.new }
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:key) { user_key(api_key.access_token) }
  describe '#index request' do
    before do
      # 5 lists
      @lists = create_list(:list, 5)
      # + 5 lists = 10
      @lists_open = create_list(:list, 5, permissions: 'open')
      # + 5 lists = 15 lists WILL NOT appear in request responses
      @lists_private = create_list(:list, 5, permissions: 'private')
      @key_user = api_key.user
      # these will not be included in request
      @lists_user = create_list(:list, 5, user: @key_user) # 5 lists
      # + 5 = 10 lists WILL appear in request responses
      @lists_user_private = create_list(:list, 5, user: @key_user, permissions: 'private')
    end
    context 'user with active key' do
      it_behaves_like 'active valid key', 'list', { :index => :get }, nil # rubocop:disable Style/HashSyntax
      it 'active status lists owned by key user returned' do
        get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
        object_owner(response_in_json, 'List', 'lists', @key_user)
      end
      it 'lists owned/returned by key user are 10' do
        get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
        lists_all = List.all
        expect(lists_all.length).to eq(25)
        expect(response_in_json['lists'].length).to eq(10)
      end
      context 'presence of attributes' do
        it 'permitted lists exclude status' do
          get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'lists', 'status', false)
        end
        it 'permitted lists include id' do
          get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'lists', 'id', true)
        end
        it 'permitted lists include name' do
          get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'lists', 'name', true)
        end
        it 'permitted lists include user_id' do
          get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'lists', 'user_id', true)
        end
        it 'permitted lists include permissions' do
          get '/api/lists', nil, 'HTTP_AUTHORIZATION' =>  key
          check_each_object(response_in_json, 'lists', 'permissions', true)
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'list', { :index => :get }, nil # rubocop:disable Style/HashSyntax
    end
    context 'user with expired key' do
      it_behaves_like 'expired key', 'list', { :index => :get }, nil # rubocop:disable Style/HashSyntax
    end
  end
  describe '#create request' do
    context 'user with active key' do
      it_behaves_like 'active valid key', 'list', { :create => :post }, { list: { name: 'my new list' } } # rubocop:disable all
      it 'responds with a list object serialized in JSON' do
        post "/api/users/#{user.id}/lists", { list: { name: 'my new list' } }, 'HTTP_AUTHORIZATION' => key
        expect(response_in_json['list']['name']).to eq('my new list')
      end
      context 'list object status' do
        it_behaves_like 'creates object with active status', 'list', { name: 'my new list' } # rubocop:disable all
      end
      context 'presence of attributes' do
        it 'serialized list excludes status' do
          post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
          check_object(response_in_json, 'list', 'status', false)
        end
        it 'serialized list includes id' do
          post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
          check_object(response_in_json, 'list', 'id', true)
        end
        it 'serialized list includes name' do
          post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
          check_object(response_in_json, 'list', 'name', true)
        end
        it 'serialized list includes user_id' do
          post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
          check_object(response_in_json, 'list', 'user_id', true)
        end
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
      it 'permissions automatically set to viewable' do
        post "/api/users/#{user.id}/lists", { list: {  name: 'my list' } }, 'HTTP_AUTHORIZATION' => key
        expect(response_in_json['list']['permissions']).to eq('viewable')
      end
      it 'enter private permissions' do
        post "/api/users/#{user.id}/lists", { list: { name: 'my list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        expect(response_in_json['list']['permissions']).to eq('private')
      end
      context 'invalid attributes' do
        context 'empty attributes' do
          context 'status code' do
            it_behaves_like 'invalid parameter returns 422', 'list', { :create => :post }, { list: { name: '', permissions: 'viewable'} } # rubocop:disable all
            it_behaves_like 'invalid parameter returns 422', 'list', { :create => :post }, { list: { name: 'my new list', permissions: '' } } # rubocop:disable all
          end
          context 'json message' do
            it_behaves_like 'invalid parameter returns error in json', 'list', { :create => :post }, { list: { name: '', permissions: 'viewable' } }, 'Name can\'t be blank' # rubocop:disable all
            it_behaves_like 'invalid parameter returns error in json', 'list', { :create => :post }, { list: { name: 'my new list', permissions: '' } }, 'Permissions is not included in the list' # rubocop:disable all
          end
        end
        context 'incorrect attributes' do
          context 'status code' do
            it_behaves_like 'invalid parameter returns 422', 'list', { :create => :post }, { list: { name: 'my new list', permissions: 'not granted' } } # rubocop:disable all
          end
          context 'json message' do
            it_behaves_like 'invalid parameter returns error in json', 'list', { :create => :post }, { list: { name: 'my new list', permissions: 'not granted' } }, 'Permissions is not included in the list' # rubocop:disable all
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'list', { :create => :post }, { list: { name: 'my list' } } # rubocop:disable all
    end
    context 'with expired key' do
      it_behaves_like 'expired key', 'list', {:create => :post}, { list: { name: 'my list' } } # rubocop:disable all
    end
    context 'user not authorized' do
      it_behaves_like 'wrong key', 'list', { :create => :post }, { list: { name: 'my list' } } # rubocop:disable all
      it_behaves_like 'wrong key with message', 'list', { :create => :post }, { list: { name: 'my list' } }, 'you are not the owner of the requested list' # rubocop:disable all
    end
  end
  describe '#update request' do
    before do
      @list_update = create(:list, user_id: user.id)
    end
    context 'user with active key' do
      it_behaves_like 'active valid key', 'list', { :update => :patch }, { list: { name: 'my updated list', permissions: 'private' } } # rubocop:disable all
      it 'saves attributes' do
        patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable all
        updated_list = List.find(@list_update.id)
        expect(updated_list.name).to eq('my new list')
        expect(updated_list.permissions).to eq('private')
      end
      context 'invalid attributes' do
        context 'empty attributes' do
          context 'status code' do
            it_behaves_like 'invalid parameter returns 422', 'list', { :update => :patch }, { list: { name: '', permissions: 'viewable'} } # rubocop:disable all
            it_behaves_like 'invalid parameter returns 422', 'list', { :update => :patch }, { list: { name: 'my new list', permissions: '' } } # rubocop:disable all
          end
          context 'json message' do
            it_behaves_like 'invalid parameter returns error in json', 'list', { :update => :patch }, { list: { name: '', permissions: 'viewable' } }, 'Name can\'t be blank' # rubocop:disable all
            it_behaves_like 'invalid parameter returns error in json', 'list', { :update => :patch }, { list: { name: 'my new list', permissions: '' } }, 'Permissions is not included in the list' # rubocop:disable all
          end
        end
        context 'incorrect attributes' do
          context 'status code' do
            it_behaves_like 'invalid parameter returns 422', 'list', { :update => :patch }, { list: { name: 'my new list', permissions: 'not granted' } } # rubocop:disable all
          end
          context 'json message' do
            it_behaves_like 'invalid parameter returns error in json', 'list', { :update => :patch }, { list: { name: 'my new list', permissions: 'not granted' } }, 'Permissions is not included in the list' # rubocop:disable all
          end
        end
      end
      context 'dependents' do
        before do
          @item_dependents = create_list(:item, 5, list_id: @list_update.id)
        end
        it 'item status remains active' do
          patch "/api/users/#{user.id}/lists/#{@list_update.id}", { list: { name: 'my new list', permissions: 'private' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
          items = Item.where(list_id: @list_update.id).all
          items.each do |item|
            expect(item.status).to eq('active')
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'list', { :update => :patch }, { list: { name: 'my new list', permissions: 'private' } } # rubocop:disable all
    end
    context 'with expired key' do
      it_behaves_like 'expired key', 'list', { :update => :patch }, { list: { name: 'my updated list', permissions: 'private' } } # rubocop:disable all
    end
    context 'user not authorized' do
      it_behaves_like 'wrong key', 'list', { :update => :patch }, { list: { name: 'my updated list', permissions: 'private' } } # rubocop:disable all
      it_behaves_like 'wrong key with message', 'list', { :update => :patch }, { list: { name: 'my updated list', permissions: 'private' } }, 'you are not the owner of the requested list' # rubocop:disable all
    end
  end
  describe '#destroy request' do
    before do
      @list_destroy = create(:list, user_id: user.id)
      @items = create_list(:item, 5, list_id: @list_destroy.id)
    end
    context 'user with active key' do
      it_behaves_like 'active valid key', 'list', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
      it 'responds with no_content' do
        delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
        expect(response).to have_http_status(:no_content)
      end
      it 'responds with code 204' do
        delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
        expect(response.status).to eq(204)
      end
      context 'list object status' do
        it_behaves_like 'destroy archives object', 'list'
      end
      context 'destroys dependents' do
        it_behaves_like 'destroy archives object dependents', 'list', 'item', 5
      end
      context 'non-existent list object' do
        it_behaves_like 'no object found', 'list'
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'list', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
    end
    context 'with expired key' do
      it_behaves_like 'expired key', 'list', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
    end
    context 'user not authorized' do
      it_behaves_like 'wrong key', 'list', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
      it_behaves_like 'wrong key with message', 'list', { :destroy => :delete }, nil, 'you are not the owner of the requested list' # rubocop:disable all
    end
  end
end

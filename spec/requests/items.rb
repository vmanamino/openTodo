require 'rails_helper'
include AuthHelper
include JsonHelper
include ExpiredKey

RSpec.describe Api::ItemsController, type: :request do
  let(:user) { create(:user) }
  let(:list) { create(:list, user: user) }
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
    context 'user with active key' do
      it_behaves_like 'active valid key', 'item', { :index => :get }, nil # rubocop:disable Style/HashSyntax
      it 'responds with all items in serialized json' do
        get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
        expect(response_in_json['items'].length).to eq(10)
      end
      it 'all items belong to key user' do
        get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
        object_owner(response_in_json, 'Item', 'items', user)
      end
      it 'number of items in response reflect ownership' do
        get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
        items_all = Item.all
        expect(items_all.length).to eq(20)
        expect(response_in_json['items'].length).to eq(10)
      end
      context 'presence of attributes' do
        it 'serialized items exclude status' do
          get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'items', 'status', false)
        end
        it 'serialized items include id' do
          get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'items', 'id', true)
        end
        it 'serialized items include name' do
          get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'items', 'name', true)
        end
        it 'serialized json includes done' do
          get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'items', 'done', true)
        end
        it 'serialized json includes list reference' do
          get '/api/items', nil, 'HTTP_AUTHORIZATION' => key
          check_each_object(response_in_json, 'items', 'list_id', true)
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'item', { :index => :get }, nil # rubocop:disable Style/HashSyntax
    end
    context 'with expired key' do
      it_behaves_like 'expired key', 'item', { :index => :get }, nil # rubocop:disable Style/HashSyntax
    end
  end
  describe '#create request' do
    context 'user with active key' do
      it_behaves_like 'active valid key', 'item', { :create => :post }, { item: { name: 'my item' } } # rubocop:disable all
      context 'item object status' do
        it_behaves_like 'creates object with active status', 'item', { name: 'my item' } # rubocop:disable all
      end
      it 'responds with object serialized in JSON' do
        post "/api/lists/#{list.id}/items", { item: { name: 'my item' } }, 'HTTP_AUTHORIZATION' => key
        expect(response_in_json['item']['name']).to eq('my item')
      end
      context 'presence of attributes' do
        it 'serialized object excludes status' do
          post "/api/lists/#{list.id}/items", { item: { name: 'get done' } }, 'HTTP_AUTHORIZATION' => key
          check_object(response_in_json, 'item', 'status', false)
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
      context 'invalid attributes' do
        context 'empty attributes' do
          context 'status code' do
            it_behaves_like 'invalid parameter returns 422', 'item', { :create => :post }, { item: { name: '', done: false } } # rubocop:disable all
            # it_behaves_like 'invalid parameter returns 422', 'item',
            # { :create => :post }, { item: { name: 'my finished item', done: '' } }
          end
          context 'json message' do
            it_behaves_like 'invalid parameter returns error in json', 'item', { :create => :post }, { item: { name: '', done: false } }, 'Name can\'t be blank' # rubocop:disable all
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :create => :post }, { item: { name: 'my finished item', done: nil } },
            # 'Done is not included in the list'
          end
        end
        context 'incorrect attributes' do
          context 'status code' do
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :create => :post }, { item: { name: 1, done: false } }
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :create => :post }, { item: { name: 'my finished item', done: 'correct' } }
          end
          context 'json message' do
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :create => :post }, { item: { name: 1, done: false } },
            # 'Name can\'t be blank'
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :create => :post }, { item: { name: 'my finished item', done: 'correct' } },
            # 'Done is not included in the list'
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'item', { :create => :post }, { item: { name: 'get it done' } } # rubocop:disable all
    end
    context 'with expired key' do
      it_behaves_like 'expired key', 'item', { :create => :post }, { item: { name: 'get it done' } } # rubocop:disable all
    end
    context 'user not authorized' do
      it_behaves_like 'wrong key', 'item', { :create => :post }, { item: { name: 'get it done' } } # rubocop:disable all
      it_behaves_like 'wrong key with message', 'item', { :create => :post }, { item: { name: 'get it done' } }, 'you are not the list owner' # rubocop:disable all
    end
  end
  describe '#update request' do
    before do
      @item_update = create(:item, list_id: list.id)
    end
    context 'user with active key' do
      it_behaves_like 'active valid key', 'item', { :update => :patch }, { item: { name: 'my finished item', done: true } } # rubocop:disable all
      it 'saves attributes' do
        patch "/api/lists/#{list.id}/items/#{@item_update.id}", { item: { name: 'my finished item', done: true } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable all
        expect(response_in_json['item']['name']).to eq('my finished item')
        expect(response_in_json['item']['done']).to eq(true)
      end
      context 'invalid attributes' do
        context 'empty attributes' do
          context 'status code' do
            it_behaves_like 'invalid parameter returns 422', 'item', { :update => :patch }, { item: { name: '', done: false } } # rubocop:disable all
            it_behaves_like 'invalid parameter returns 422', 'item', { :update => :patch }, { item: { name: 'my finished item', done: '' } } # rubocop:disable all
          end
          context 'json message' do
            it_behaves_like 'invalid parameter returns error in json', 'item', { :update => :patch }, { item: { name: '', done: false } }, 'Name can\'t be blank' # rubocop:disable all
            it_behaves_like 'invalid parameter returns error in json', 'item', { :update => :patch }, { item: { name: 'my finished item', done: '' } }, 'Done is not included in the list' # rubocop:disable all
          end
        end
        context 'incorrect attributes' do
          context 'status code' do
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :update => :patch }, { item: { name: 1, done: false } }
            it_behaves_like 'invalid parameter returns 422', 'item', { :update => :patch }, { item: { name: 'my finished item', done: nil } } # rubocop:disable all
          end
          context 'json message' do
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :update => :patch }, { item: { name: 1, done: false } },
            # 'Name can\'t be blank'
            # it_behaves_like 'invalid parameter returns error in json', 'item',
            # { :update => :patch }, { item: { name: 'my finished item', done: 'yes' } },
            # 'Done is not included in the list'
            it_behaves_like 'invalid parameter returns error in json', 'item', { :update => :patch }, { item: { name: 'my finished item', done: nil } }, 'Done is not included in the list' # rubocop:disable all
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'item', { :update => :patch }, { item: { name: 'my finished item', done: true } } # rubocop:disable all
    end
    context 'with expired key' do
      it_behaves_like 'expired key', 'item', { :update => :patch }, { item: { name: 'my finished item', done: true } } # rubocop:disable all
    end
    context 'user not authorized' do
      it_behaves_like 'wrong key', 'item', { :update => :patch }, { item: { name: 'my finished item', done: true } } # rubocop:disable all
      it_behaves_like 'wrong key with message', 'item', { :update => :patch }, { item: { name: 'my finished item', done: true } }, 'you are not the list owner' # rubocop:disable all
    end
  end
end

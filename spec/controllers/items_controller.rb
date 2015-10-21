require 'rails_helper'
include AuthHelper
include JsonHelper
include ExpiredKey

RSpec.describe Api::ItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:list) { create(:list, user: user) }
  describe '#index' do
    before do
      @list_two = create(:list, user: user)
      @items_list_one_user = create_list(:item, 5, list: list)
      @items_list_two_user = create_list(:item, 5, list: @list_two)
      @items_list_other = create_list(:item, 5)
    end
    context 'user with active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'index with active valid key'
      it 'responds with items in serialized json' do
        get :index
        expect(response_in_json['items'].length).to eq(10)
      end
      it 'serialized items all belong to owner' do
        get :index
        object_owner(response_in_json, 'Item', 'items', user)
      end
      it 'number of serialized items in response reflect ownership' do
        get :index
        items_all = Item.all
        expect(items_all.length).to eq(15)
        expect(response_in_json['items'].length).to eq(10)
      end
      it 'serialized items include id' do
        get :index
        check_each_object(response_in_json, 'items', 'id', true)
      end
      it 'serialized items include name' do
        get :index
        check_each_object(response_in_json, 'items', 'name', true)
      end
      it 'serialized items include done' do
        get :index
        check_each_object(response_in_json, 'items', 'done', true)
      end
      it 'serialized items include list reference' do
        get :index
        check_each_object(response_in_json, 'items', 'list_id', true)
      end
    end
    context 'user without key' do
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
    context 'user with active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with active valid key', 'item', { name: 'get it done' }
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
      context 'invalid empty name' do
        it 'failure responds with appropriate message for absent name' do
          http_key_auth
          post :create, list_id: list.id, item: { name: ' ' }
          expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'create unauthorized', 'item', { name: 'get it done' }
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with expired key', 'item', { name: 'get it done' }
    end
    context 'user with wrong key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with the wrong key', 'item', { name: 'get it done' }
      it_behaves_like 'create with the wrong key message', 'item', { name: 'get it done' }, 'you are not the list owner'
    end
  end
  describe '#update' do
    before do
      @item_update = create(:item, list_id: list.id)
    end
    context 'user with active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'update with active valid key', 'item', item: { name: 'my finished item', done: true }
      it 'saves attributes' do
        patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: true }
        updated_item = Item.find(@item_update.id)
        expect(updated_item.name).to eq('my finished item')
        expect(updated_item.done).to be true
      end
      context 'invalid/empty attributes' do
        it 'raises exception status' do
          patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: nil }
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'responds with 422 code' do
          patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: nil }
          expect(response.status).to eq(422)
        end
        it 'responds with appropriate error message' do
          patch :update, list_id: list.id, id: @item_update.id, item: { name: 'my finished item', done: nil }
          expect(response_in_json['errors'][0]).to eq('Done is not included in the list')
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'update unauthorized', 'item', { name: 'my finished item', done: true }
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'update with expired key', 'item', item: { name: 'my finished item', done: true }
    end
    context 'user with wrong key' do
      before do
        http_key_auth
      end
      it_behaves_like 'update with the wrong key', 'item', { name: 'my finished item', done: true }
      it_behaves_like 'update with the wrong key message', 'item', { name: 'my finished item', done: true }, 'you are not the list owner'
    end
  end
end

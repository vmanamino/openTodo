require 'rails_helper'
include AuthHelper
include JsonHelper
include ExpiredKey

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  describe '#index' do
    before do
      @users = create_list(:user, 5)
    end
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'index with active valid key'
      it 'returns users serialized in json' do
        get :index
        expect(response_in_json['users'].length).to eq(6)
      end
      it 'serialized json excludes private attributes' do
        get :index
        check_each_object(response_in_json, 'password', false)
      end
      it 'serialized json includes specified attributes in UserSerializer' do
        get :index
        check_each_object(response_in_json, 'id', true)
        check_each_object(response_in_json, 'username', true)
      end
    end
    it 'unauthenticated user responds with http unauthorized' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
    context 'user without key' do
      it_behaves_like 'index unauthorized'
    end
    context 'user with expired key' do
      it_behaves_like 'index with expired key'
    end
  end
  describe '#create' do
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with active valid key', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
      it 'renders newly created user in JSON format' do
        http_key_auth
        post :create, user: { username: 'newone', password: 'noone' }
        expect(response_in_json['user']['username']).to eq('newone')
      end
      it 'serialized JSON excludes private attributes' do
        http_key_auth
        post :create, user: { username: 'newone', password: 'noone' }
        check_object(response_in_json, 'password', false)
      end
      it 'serialized JSON includes attribute id' do
        http_key_auth
        post :create, user: { username: 'newone', password: 'noone' }
        check_object(response_in_json, 'id', true)
      end
      it 'serialized JSON includes attribute username' do
        http_key_auth
        post :create, user: { username: 'newone', password: 'noone' }
        check_object(response_in_json, 'username', true)
      end
      it 'username matches value given' do
        http_key_auth
        post :create, user: { username: 'newone', password: 'noone' }
        expect(response_in_json['user']['username']).to eq('newone')
      end
      context 'invalid attributes' do
        context 'empty attributes' do
          context '422' do
            it_behaves_like 'create invalid parameter returns 422', 'user', { username: 'newone', password: '' } # rubocop:disable all
            it_behaves_like 'create invalid parameter returns 422', 'user', { username: '', password: 'noone' } # rubocop:disable all
          end
          context 'json' do
            it_behaves_like 'create invalid parameter returns error in json', 'user', { username: 'newone', password: '' }, 'Password can\'t be blank' # rubocop:disable all
            it_behaves_like 'create invalid parameter returns error in json', 'user', { username: '', password: 'noone' }, 'Username can\'t be blank' # rubocop:disable all
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'create unauthorized', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with expired key', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
    end
  end
  describe '#destroy' do
    before do
      @user_destroy = create(:user)
      @lists = create_list(:list, 5, user_id: @user_destroy.id)
    end
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with active valid key', 'user'
      context 'non-existent user object' do
        it_behaves_like 'no object found controller', 'user'
      end
      it 'destroys list dependents' do
        all_lists = List.all
        expect(all_lists.length).to eq(5)
        http_key_auth
        delete :destroy, id: @user_destroy.id
        all_lists.reload
        expect(all_lists.length).to eq(0)
      end
    end
    context 'user without key' do
      it_behaves_like 'destroy unauthorized', 'user'
    end
    context 'user with expired key' do
      it_behaves_like 'destroy with expired key', 'user'
    end
  end
end

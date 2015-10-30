require 'rails_helper'
include JsonHelper
include AuthHelper
include ExpiredKey

RSpec.describe Api::UsersController, type: :request do
  let(:controller) { Api::UsersController.new }
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:key) { user_key(api_key.access_token) }
  describe '#create request' do
    context 'user with active valid key' do
      it_behaves_like 'active valid key', 'user', { :create => :post }, { user: { username: 'my new name', password: 'is special' } } # rubocop:disable all
      it 'responds with serialized user' do
        post '/api/users', { user: { username: 'my new name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        expect(response_in_json['user']['username']).to eq('my new name')
      end
      context 'object user status' do
        it_behaves_like 'creates object with active status', 'user', { username: 'my new name', password: 'is special' } # rubocop:disable all
      end
      context 'presence of attributes' do
        it 'serialized user excludes private attributes' do
          post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
          check_object(response_in_json, 'password', false)
          check_object(response_in_json, 'status', false)
        end
        it 'serialized user includes id' do
          post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
          check_object(response_in_json, 'id', true)
        end
        it 'serialized user includes username' do
          post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
          check_object(response_in_json, 'username', true)
        end
      end
      it 'username matches value given' do
        post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        expect(response_in_json['user']['username']).to eq('my name')
      end
      context 'invalid attributes' do
        context 'empty attributes' do
          context '422' do
            it_behaves_like 'invalid parameter returns 422', 'user', { :create => :post }, { user: { username: 'newone', password: '' } } # rubocop:disable all
            it_behaves_like 'invalid parameter returns 422', 'user',  { :create => :post }, { user: { username: '', password: 'noone' } } # rubocop:disable all
          end
          context 'json' do
            it_behaves_like 'invalid parameter returns error in json', 'user', { :create => :post }, { user: { username: 'newone', password: '' } }, 'Password can\'t be blank' # rubocop:disable all
            it_behaves_like 'invalid parameter returns error in json', 'user',  { :create => :post }, { user: { username: '', password: 'noone' } }, 'Username can\'t be blank' # rubocop:disable all
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'user', { :create => :post }, { user: { username: 'my name', password: 'is special' } } # rubocop:disable all
    end
    context 'user with expired valid key' do
      it_behaves_like 'expired key', 'user', { :create => :post }, { user: { username: 'my name', password: 'is special' } } # rubocop:disable all
    end
  end
  describe '#destroy' do
    before do
      @user_destroy = user
      @user_lists = create_list(:list, 5, user: @user_destroy)
      @user_keys = create_list(:api_key, 5, user: @user_destroy)
      @user_other = create(:user)
    end
    context 'user with active valid key' do
      it_behaves_like 'active valid key', 'user', { :destroy => :delete }, { user: { username: 'my name', password: 'is special' } } # rubocop:disable all
      it 'responds with no_content' do
        delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
        expect(response).to have_http_status(:no_content)
      end
      it 'responds with code 204' do
        delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
        expect(response.status).to eq(204)
      end
      context 'user object status' do
        it_behaves_like 'destroy archives object', 'user'
      end
      context 'destroy dependents' do
        it_behaves_like 'destroy archives object dependents', 'user', 'list', 5
        it_behaves_like 'destroy archives object dependents', 'user', 'api_key', 5
      end
      context 'destroy grandchildren' do # grandchildren are items of lists belonging to user
        before do # create grandchildren items
          @user_lists.each do |list|
            create(:item, list: list)
          end
          @user_items = Item.all
        end
        it 'archives all items belonging to user lists' do
          delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
          expect(Item.where(status: 0).all.length).to eq(0)
          @user_items.each do |item|
            expect(item.status).to eq('archived')
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'user', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
    end
    context 'user with expired valid key' do
      it_behaves_like 'expired key', 'user', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
    end
    context 'user not authorized' do
      it_behaves_like 'wrong key', 'user', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
      it_behaves_like 'wrong key with message', 'user', { :destroy => :delete }, nil, 'you are not the user' # rubocop:disable all
    end
  end
end

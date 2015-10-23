require 'rails_helper'
include JsonHelper
include AuthHelper
include ExpiredKey

RSpec.describe Api::UsersController, type: :request do
  let(:controller) { Api::UsersController.new }
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:key) { user_key(api_key.access_token) }
  describe '#index request' do
    before do
      @users = create_list(:user, 5)
    end
    context 'user with active valid key' do
      it_behaves_like 'active valid key', 'user', { :index => :get }, nil # rubocop:disable Style/HashSyntax
      it 'responds with serialized users' do
        get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
        expect(response_in_json['users'].length).to eq(6) # 1 extra for the user needed to create api_key
      end
      it 'serialized users exclude password' do
        get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
        check_each_object(response_in_json, 'password', false)
      end
      it 'serialized users include id' do
        get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
        check_each_object(response_in_json, 'id', true)
      end
      it 'serialized users include username' do
        get '/api/users', nil, 'HTTP_AUTHORIZATION' => key
        check_each_object(response_in_json, 'username', true)
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'user', { :index => :get }, nil # rubocop:disable Style/HashSyntax
    end
    context 'expired key' do
      it_behaves_like 'expired key', 'user', { :index => :get }, nil # rubocop:disable Style/HashSyntax
    end
  end
  describe '#create request' do
    context 'user with active valid key' do
      it_behaves_like 'active valid key', 'user', { :create => :post }, { user: { username: 'my new name', password: 'is special' } } # rubocop:disable all
      it 'responds with serialized user' do
        post '/api/users', { user: { username: 'my new name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        expect(response_in_json['user']['username']).to eq('my new name')
      end
      it 'serialized user excludes private attribute' do
        post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        check_object(response_in_json, 'password', false)
      end
      it 'serialized user includes id' do
        post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        check_object(response_in_json, 'id', true)
      end
      it 'serialized user includes username' do
        post '/api/users', { user: { username: 'my name', password: 'is special' } }, 'HTTP_AUTHORIZATION' => key # rubocop:disable Metrics/LineLength
        check_object(response_in_json, 'username', true)
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
      @user_destroy = create(:user)
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
      context 'non-existent user object' do
        it_behaves_like 'no object found', 'user', nil
      end
    end
    context 'user without key' do
      it_behaves_like 'unauthenticated user', 'user', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
    end
    context 'user with expired valid key' do
      it_behaves_like 'expired key', 'user', { :destroy => :delete }, nil # rubocop:disable Style/HashSyntax
    end
  end
end

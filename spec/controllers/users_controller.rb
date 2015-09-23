require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  describe '#index' do
    before do
      @users = create_list(:user, 5)
    end
    it 'unauthenticated user responds with http unauthorized' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
    it 'expired key responds with http unauthorized' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
    it 'authenticated user responds with http success' do
      http_key_auth
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'returns users serialized in json' do
      http_key_auth
      get :index
      expect(response_in_json['users'].length).to eq(6)
    end
    it 'serialized json excludes private attributes' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'password', false)
    end
    it 'serialized json includes specified attributes in UserSerializer' do
      http_key_auth
      get :index
      check_each_object(response_in_json, 'id', true)
      check_each_object(response_in_json, 'username', true)
    end
    it 'no authenticated user responds with 401 status code' do
      get :index
      expect(response.status).to eq(401)
    end
    it 'authenticated user responds with 200 status code' do
      http_key_auth
      get :index
      expect(response.status).to eq(200)
    end
  end
  describe '#create' do
    it 'unauthenticated user responds as http unauthorized' do
      post :create, user: { username: user.username, password: user.password }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'unauthenticated user responds with 401 status' do
      post :create, user: { username: user.username, password: user.password }
      expect(response.status).to eq(401)
    end
    it 'expired key responds with http unauthorized' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      expect(response).to have_http_status(:unauthorized)
    end
    it 'authenticated user responds as http success' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      expect(response).to have_http_status(:success)
    end
    it 'authenticated user responds with 200 status' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      expect(response.status).to eq(200)
    end
    it 'renders newly created user in JSON format' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      expect(response_in_json['user']['username']).to eq(user.username)
    end
    it 'serialized JSON excludes private attributes' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      check_object(response_in_json, 'password', false)
    end
    it 'serialized JSON includes attribute id' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      check_object(response_in_json, 'id', true)
    end
    it 'serialized JSON includes attribute username' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      check_object(response_in_json, 'username', true)
    end
    it 'username matches value given' do
      http_key_auth
      post :create, user: { username: user.username, password: user.password }
      expect(response_in_json['user']['username']).to eq(user.username)
    end
    it 'failure responds with appropriate message for absent password' do
      http_key_auth
      post :create, user: { username: user.username, password: ' ' }
      expect(response_in_json['errors'][0]).to eq('Password can\'t be blank')
    end
    it 'failure responds with appropriate message for absent username' do
      http_key_auth
      post :create, user: { username: ' ', password: user.password }
      expect(response_in_json['errors'][0]).to eq('Username can\'t be blank')
    end
  end
  describe '#destroy' do
    let(:user_destroy) { create(:user) }
    let(:controller) { Api::UsersController.new }
    before do
      @lists = create_list(:list, 5, user_id: user_destroy.id)
    end
    it 'responds with status no_content' do
      http_key_auth
      delete :destroy, id: user_destroy.id
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with status code 204' do
      http_key_auth
      delete :destroy, id: user_destroy.id
      expect(response.status).to eq(204)
    end
    it 'responds with unauthorized to unauthenticated user' do
      delete :destroy, id: user_destroy.id
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with 401 code to unauthenticated user' do
      delete :destroy, id: user_destroy.id
      expect(response.status).to eq(401)
    end
    it 'responds with http unauthorized to expired key' do
      api_key.expires_at = 1.day.ago
      api_key.save
      http_key_auth
      delete :destroy, id: user_destroy.id
      expect(response).to have_http_status(:unauthorized)
    end
    it 'raises exception status not_found' do
      http_key_auth
      delete :destroy, id: 100
      expect(response).to have_http_status(:not_found)
    end
    it 'raises not found code 404' do
      http_key_auth
      delete :destroy, id: 100
      expect(response.status).to eq(404)
    end
    it 'destroys list dependents' do
      all_lists = List.all
      expect(all_lists.length).to eq(5)
      http_key_auth
      delete :destroy, id: user_destroy.id
      all_lists.reload
      expect(all_lists.length).to eq(0)
    end
  end
end

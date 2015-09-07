require 'rails_helper'
include AuthHelper
include JsonHelper

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user) } # required for http_login below

  describe '#index' do
    before do
      @users = create_list(:user, 5)
    end
    it 'unauthenticated user responds with http unauthorized' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
    it 'authenticated user responds with http success' do
      http_login
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'returns users serialized in json' do
      http_login
      get :index
      expect(response_in_json['users'].length).to eq(6)
    end
    it 'serialized json excludes private attributes' do
      http_login
      get :index
      check_each_object(response_in_json, 6, 'password', false)
    end
    it 'serialized json includes specified attributes in UserSerializer' do
      http_login
      get :index
      check_each_object(response_in_json, 6, 'id', true)
      check_each_object(response_in_json, 6, 'username', true)
    end
    it 'no authenticated user responds with 401 status code' do
      get :index
      expect(response.status).to eq(401)
    end
    it 'authenticated user responds with 200 status code' do
      http_login
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
    it 'authenticated user responds as http success' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      expect(response).to have_http_status(:success)
    end
    it 'authenticated user responds with 200 status' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      expect(response.status).to eq(200)
    end
    it 'renders newly created user in JSON format' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      expect(response_in_json['user']['username']).to eq(user.username)
    end
    it 'serialized JSON excludes private attributes' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      check_object(response_in_json, 'password', false)
    end
    it 'serialized JSON includes attribute id' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      check_object(response_in_json, 'id', true)
    end
    it 'serialized JSON includes attribute username' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      check_object(response_in_json, 'username', true)
    end
    it 'username matches value given' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      expect(response_in_json['user']['username']).to eq(user.username)
    end
    it 'failure responds with appropriate message for absent password' do
      http_login
      post :create, user: { username: user.username, password: ' ' }
      expect(response_in_json['errors'][0]).to eq('Password can\'t be blank')
    end
    it 'failure responds with appropriate message for absent username' do
      http_login
      post :create, user: { username: ' ', password: user.password }
      expect(response_in_json['errors'][0]).to eq('Username can\'t be blank')
    end
  end
  describe '#destroy' do
    let(:user_destroy) { create(:user) }
    let(:controller) { Api::UsersController.new }
    it 'responds with status no_content' do
      http_login
      delete :destroy, id: user_destroy.id
      expect(response).to have_http_status(:no_content)
    end
    it 'responds with status code 204' do
      http_login
      delete :destroy, id: user_destroy.id
      expect(response.status).to eq(204)
    end
    it 'responsds with anauthorized to unauthenticated user' do
      delete :destroy, id: user_destroy.id
      expect(response).to have_http_status(:unauthorized)
    end
    it 'responds with 401 code to unauthenticated user' do
      delete :destroy, id: user_destroy.id
      expect(response.status).to eq(401)
    end
    it 'raises exception' do
      http_login
      allow(controller).to receive(:destroy) { fail ActiveRecord::RecordNotFound }
      expect { controller.destroy }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end

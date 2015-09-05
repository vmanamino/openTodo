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
      json = JSON.parse(response.body)
      expect(json['users'].length).to eq(6)
    end
    it 'serialized json excludes private attributes' do
      http_login
      get :index
      json = JSON.parse(response.body)
      check_each_user(json, 6, 'password', false)
    end
    it 'serialized json includes specified attributes in UserSerializer' do
      http_login
      get :index
      json = JSON.parse(response.body)
      check_each_user(json, 6, 'id', true)
      check_each_user(json, 6, 'username', true)
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
      json = JSON.parse(response.body)
      expect(json['user']['username']).to eq(user.username)
    end
    it 'serialized JSON excludes private attributes' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      json = JSON.parse(response.body)
      check_user(json, 'password', false)
    end
    it 'serialized JSON includes attribute id' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      json = JSON.parse(response.body)
      check_user(json, 'id', true)
    end
    it 'serialized JSON includes attribute username' do
      http_login
      post :create, user: { username: user.username, password: user.password }
      json = JSON.parse(response.body)
      check_user(json, 'username', true)
    end
  end
end

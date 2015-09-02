require 'rails_helper'
include AuthHelper

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user) } # required for http_login below

  # method to check presence of attribute
  def check_each_user(collection, name = 'users', elements, attribute, boolean)
    counter = 0
    while counter < elements
      expect(collection[name][counter].key?(attribute)).to be boolean
      counter += 1
    end
  end

  describe '#index' do
    before do
      @users = create_list(:user, 5)
    end
    it 'no authenticated user responds with http unauthorized' do
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
      get :index, users: user
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
end

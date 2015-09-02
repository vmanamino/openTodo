require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  let(:controller) { Api::UsersController.new }
   # method to check presence of attribute
  def check_each_user(collection, name = 'users', elements, attribute, boolean)
    counter = 0
    while counter < elements
      expect(collection[name][counter].key?(attribute)).to be boolean
      counter += 1
    end
  end
  describe '#index request' do
    before do
      @users = create_list(:user, 5)
      controller.class.skip_before_filter :authenticated?
    end
    it 'status is 200' do
      get '/api/users'
      expect(response.status).to eq(200)
    end
    it 'responds with serialized users' do
      get '/api/users'
      json = JSON.parse(response.body)
      expect(json['users'].length).to eq(5)
    end
    it 'serialized users exclude private attribute' do
      get '/api/users'
      json = JSON.parse(response.body)
      check_each_user(json, 5, 'password', false)
    end
    it 'serialized users include id' do
      get '/api/users'
      json = JSON.parse(response.body)
      check_each_user(json, 5, 'id', true)
    end
    it 'serialized users include username' do
      get '/api/users'
      json = JSON.parse(response.body)
      check_each_user(json, 5, 'username', true)
    end
  end
end
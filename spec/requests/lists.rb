require 'rails_helper'
include JsonHelper
include AuthHelper

RSpec.describe Api::ListsController, type: :request do
  let(:controller) { Api::ListsController.new }
  let(:user) { create(:user) }
  describe '#create request' do
    before do
      controller.class.skip_before_filter :authenticated?
    end
    it 'responds with serialized list' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      expect(response_in_json.length).to eq(1)
    end
    it 'serialized list includes id' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'serialized list includes name' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      check_object(response_in_json, 'list', 'id', true)
    end
    it 'serialized list includes user_id' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      check_object(response_in_json, 'list', 'user_id', true)
    end
    it 'user_id belongs to user' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list' }
      expect(response_in_json['list']['user_id']).to eq(user.id)
    end
    it 'permissions automatically set to public' do
      post "/api/users/#{user.id}/lists", list: {  name: 'my list' }
      expect(response_in_json['list']['permissions']).to eq('public')
    end
    it 'enter private permissions' do
      post "/api/users/#{user.id}/lists", list: { name: 'my list', permissions: 'private' }
      expect(response_in_json['list']['permissions']).to eq('private')
    end
    it 'responds with sucess to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, { 'HTTP_AUTHORIZATION' => credentials }
      expect(response).to have_http_status(:success)
    end
    it 'responds with unauthorized to unauthenticated user' do
      controller.class.before_filter :authenticated?
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, { 'HTTP_AUTHORIZATION' => nil }
    end
    it 'responds with serialized list to authenticated user' do
      controller.class.before_filter :authenticated?
      credentials = user_credentials(user.username, user.password)
      post "/api/users/#{user.id}/lists", { list: { name: 'my list' } }, { 'HTTP_AUTHORIZATION' => credentials }
      expect(response_in_json.length).to eq(1)
    end
    it 'failure responds with appropriate error message for absent name' do
      post "/api/users/#{user.id}/lists", list: { name: ' ' }
      expect(response_in_json['errors'][0]).to eq('Name can\'t be blank')
    end
  end
end

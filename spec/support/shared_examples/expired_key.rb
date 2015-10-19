require 'rails_helper'
require 'support/path_helper'
# include AuthHelper
include PathHelper

shared_examples 'expired key' do |object, verb_pair, parameters|
  it 'responds with unauthorized', type: :request do
    user = create(:user)
    api_key = create(:api_key, user: user)
    api_key.expires_at = 1.day.ago
    api_key.save
    key = user_key(api_key.access_token)
    list = create(:list, user: user)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action, user, list)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

shared_examples 'index with expired key' do
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    get :index
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'create with expired key' do |object, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        post :create, user_id: user.id, list: parameters
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'update with expired key' do |object, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:list) { create(:list, user: user) }
  let(:item) { create(:item, list: list) }
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        patch :update, user_id: user.id, id: list.id, list: parameters
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'destroy with expired key' do |object|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:list) { create(:list, user: user) }
  let(:item) { create(:item, list: list) }
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        delete :destroy, user_id: user.id, id: list.id
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

module ExpiredKey
  def expire_key(api_key)
    api_key.expires_at = 1.day.ago
    api_key.save
  end
end
require 'rails_helper'
require 'support/path_helper'
include PathHelper

shared_examples 'expired key' do |object, verb_pair, parameters|
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :request do
    verb_pair.each_pair do |action, request|
      path = build_path(object, action)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

shared_examples 'index with expired key' do
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    get :index
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'create with expired key' do |object, parameters|
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    case object
    when 'user'
      post :create, user: parameters
    when 'list'
      post :create, user_id: user.id, list: parameters
    when 'item'
      post :create, list_id: list.id, item: parameters
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'update with expired key' do |object, parameters|
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    case object
    when 'list'
      patch :update, user_id: user.id, id: @list_update.id, list: parameters
    when 'item'
      patch :update, list_id: list.id, id: @item_update.id, item: parameters
    end
    # binding.pry
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'destroy with expired key' do |object|
  before do
    expire_key(api_key)
  end
  it 'responds with unauthorized', type: :controller do
    case object
    when 'user'
      delete :destroy, id: @user_destroy.id
    when 'list'
      delete :destroy, user_id: user.id, id: @list_destroy.id
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

require 'rails_helper'
require 'support/path_helper'
include PathHelper

shared_examples 'unauthenticated user' do |object, verb_pair, parameters|
  it 'responds with unauthorized', type: :request do
    verb_pair.each_pair do |action, request|
      path = build_path(object, action)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => nil)
      # binding.pry
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

shared_examples 'index unauthorized' do
  it 'responds with unauthorized' do
    get :index
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'create unauthorized' do |object, parameters|
  it 'responds with unauthorized' do
    case object
      when 'list'
        post :create, user_id: user.id, list: parameters
      when 'item'
        post :create, list_id: list.id, item: parameters
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'update unauthorized' do |object, parameters|
  it 'responds with unauthorized' do
    case object
      when 'list'
        patch :update, user_id: user.id, id: @list_update.id, list: parameters
      when 'item'
        patch :update, list_id: list.id, id: @item_update.id, item: parameters
    end
  end
end
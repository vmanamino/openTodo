require 'rails_helper'
require 'support/path_helper'
# include AuthHelper
include PathHelper


shared_examples 'active key' do |object, verb_pair, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:list) { create(:list, user: user) }
  it 'responds with success', type: :request do
    key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action, user, list)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response).to have_http_status(:success)
    end
  end
end

shared_examples 'index with active valid key' do
  it 'responds with success', type: :controller do
    get :index
    # binding.pry
    expect(response).to have_http_status(:success)
  end
end

shared_examples 'create with active valid key' do |object, parameters|
  it 'responds with success' do
    case object
      when 'list'
        post :create, user_id: user.id, list: parameters
      when 'item'
        post :create, list_id: list.id, item: parameters
    end
    # binding.pry
    expect(response).to have_http_status(:success)
  end
end

shared_examples 'update with active valid key' do |object, parameters|
  it 'responds with success' do
    case object
      when 'list'
        patch :update, user_id: user.id, id: @list_update.id, list: parameters
      when 'item'
        patch :update, list_id: list.id, id: @item_update.id, item: parameters
    end
    expect(response).to have_http_status(:success)
  end
end

shared_examples 'destroy with active valid key' do |object|
  it 'responds with no content and 204' do
    case object
      when 'list'
        delete :destroy, user_id: user.id, id: @list_destroy.id
    end
    expect(response).to have_http_status(:no_content)
    expect(response.status).to eq(204)
  end
end


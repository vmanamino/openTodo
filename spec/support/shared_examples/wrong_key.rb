require 'rails_helper'
require 'support/path_helper'
include PathHelper

shared_examples 'wrong key' do |object, verb_pair, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  it 'responds with unauthorized', type: :request do
    key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action, user, list)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

shared_examples 'wrong key with message' do |object, verb_pair, parameters, message|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  it 'responds with unauthorized', type: :request do
    key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action, user, list)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response_in_json['message']).to eq(message)
    end
  end
end

shared_examples 'create with wrong key' do |object, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  it 'responds with unauthorized', type: :controller do
    case object
      when 'list'
        http_key_auth
        post :create, user_id: user.id, list: parameters
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'create with the wrong key message' do |object, parameters, message|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  it 'responds with unauthorized', type: :controller do
    case object
      when 'list'
        http_key_auth
        post :create, user_id: user.id, list: parameters
    end
    expect(response_in_json['message']).to eq(message)
  end
end

shared_examples 'update with the wrong key' do |object, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  let(:item) { create(:item, list: list) }
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        patch :update, user_id: user.id, id: list.id, list: parameters
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'update with the wrong key message' do |object, parameters, message|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  let(:item) { create(:item, list: list) }
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        patch :update, user_id: user.id, id: list.id, list: parameters
    end
    expect(response_in_json['message']).to eq(message)
  end
end

shared_examples 'destroy with the wrong key' do |object|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  let(:item) { create(:item, list: list) }
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        delete :destroy, user_id: user.id, id: list.id
    end
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_examples 'destroy with the wrong key message' do |object, message|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  let(:item) { create(:item, list: list) }
  it 'responds with unauthorized', type: :controller do
    http_key_auth
    case object
      when 'list'
        delete :destroy, user_id: user.id, id: list.id
    end
    expect(response_in_json['message']).to eq(message)
  end
end


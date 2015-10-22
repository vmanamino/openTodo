require 'rails_helper'
require 'support/path_helper'
include PathHelper

shared_examples 'invalid parameter returns 422' do |object, verb_pair, parameters|
  it 'responds with 422', type: :request do
    key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
    end
    # binding.pry
    expect(response.status).to eq(422)
  end
end

shared_examples 'invalid parameter returns error in json' do |object, verb_pair, parameters, message|
  it 'responds with json', type: :request do
    key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
    end
    # binding.pry
    expect(response_in_json['errors'][0]).to eq(message)
  end
end

shared_examples 'create invalid parameter returns 422' do |object, parameters|
  it 'responds with 422' do
    case object
      when 'list'
        post :create, user_id: user.id, list: parameters
      when 'item'
        post :create, list_id: list.id, item: parameters
    end
    expect(response.status).to eq(422)
  end
end

shared_examples 'create invalid parameter returns error in json' do |object, parameters, message|
  it 'responds with json' do
    case object
      when 'list'
        post :create, user_id: user.id, list: parameters
      when 'item'
        post :create, list_id: list.id, item: parameters
    end
    expect(response_in_json['errors'][0]).to eq(message)
  end
end

shared_examples 'update invalid parameter returns 422' do |object, parameters|
  it 'responds with 422', type: :controller do
    case object
      when 'list'
        patch :update, user_id: user.id, id: @list_update.id, list: parameters
      when 'item'
        patch :update, list_id: list.id, id: @item_update.id, item: parameters
    end
    expect(response.status).to eq(422)
  end
end

shared_examples 'update invalid parameter returns error in json' do |object, parameters, message|
  it 'responds with json', type: :controller do
    case object
      when 'list'
        patch :update, user_id: user.id, id: @list_update.id, list: parameters
      when 'item'
        patch :update, list_id: list.id, id: @item_update.id, item: parameters
    end
    expect(response_in_json['errors'][0]).to eq(message)
  end
end

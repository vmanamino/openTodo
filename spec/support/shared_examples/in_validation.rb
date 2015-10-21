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
    expect(response_in_json['errors'][0]).to eq(message)
  end
end

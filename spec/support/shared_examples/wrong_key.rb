require 'rails_helper'
require 'support/path_helper'
include PathHelper

shared_examples 'wrong key' do |object, verb_pair, parameters|
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:list) { create(:list, user: user) }
  it 'responds with unauthorized' do
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
  it 'responds with unauthorized' do
    key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, request|
      path = build_path(object, action, user, list)
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response_in_json['message']).to eq(message)
    end
  end
end


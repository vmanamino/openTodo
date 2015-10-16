require 'rails_helper'
require 'support/path_helper'
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
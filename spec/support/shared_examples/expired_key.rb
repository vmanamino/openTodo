require 'rails_helper'

shared_examples 'expired key' do |verb, path, model, parameters, api_key|
  let(:resources) { model.to_s.tableize }
  it 'responds with unauthorized', type: :request do
    api_key = create(api_key)
    api_key.expires_at = 1.day.ago
    api_key.save
    user = api_key.user
    key = user_key(api_key.access_token)
    verb.each_pair do |action, request|
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
require 'rails_helper'

shared_examples 'expired key' do |verb, path, model, parameters, api_key|
  let(:resources) { model.to_s.tableize }
  it 'responds with unauthorized', type: :request do
    user = create(:user)
    api_key = create(api_key, user: user )
    api_key.expires_at = 1.day.from_now
    api_key.save
    key = user_key(api_key.access_token)
    # api_key = create(api_key)
    #api_key.expires_at = 1.day.from_now
    # api_key.save
    # user = api_key.user
    # list = create(:list, user: user)
    # key = user_key(api_key.access_token)
    verb.each_pair do |action, request|
      send(request, path, parameters, 'HTTP_AUTHORIZATION' => key)
      # binding.pry
      expect(response).to have_http_status(:success)
    end
  end
end
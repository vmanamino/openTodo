require 'rails_helper'
require 'support/path_helper'
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

shared_examples 'action with active key' do |object, verb_pair, post_data=nil, user|
  # let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  let(:list) { create(:list, user: user) }
  it 'responds with success', type: :controller do
    # key = user_key(api_key.access_token)
    verb_pair.each_pair do |action, verb|
      case object
        when 'list'
          case action
            when :index
              send(verb, action)
            when :create
              send(verb, action, user, post_data)
          end
      end
      # binding.pry
      expect(response).to have_http_status(:success)
    end
  end
end


require 'rails_helper'
require 'support/json_helper'
require 'support/status_helper'
include StatusHelper

shared_examples 'index objects active status' do |objects|
  it 'collects active objects belonging to user', type: :request do
    case objects
    when 'lists'
      get '/api/lists', nil, 'HTTP_AUTHORIZATION' => key
      check_status(response_in_json, 'lists', 'active')
    end
  end
end


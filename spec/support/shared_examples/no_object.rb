require 'rails_helper'
require 'support/path_helper'
include PathHelper

shared_examples 'no object found' do |object|
  path = ''
  it 'responds with 404 object not found', type: :request do
    case object
    when 'user'
      path = '/api/users/100'
    when 'list'
      path = "/api/users/#{user.id}/lists/100"
    end
    send(:delete, path, nil, 'HTTP_AUTHORIZATION' => key)
    expect(response).to have_http_status(:not_found)
    expect(response.status).to eq(404)
  end
end

shared_examples 'no object found controller' do |object|
  it 'responds with 404 object not found', type: :controller do
    case object
    when 'user'
      delete :destroy, id: 100
    when 'list'
      delete :destroy, user_id: user.id, id: 100
    end
    expect(response).to have_http_status(:not_found)
    expect(response.status).to eq(404)
  end
end

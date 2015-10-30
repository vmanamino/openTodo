require 'rails_helper'
require 'support/json_helper'
require 'support/status_helper'
include StatusHelper

# shared_examples 'index objects active status' do |objects|
#   it 'collects active objects belonging to user', type: :controller do
#     case objects
#     when 'lists'
#       get index
#     end
#     # binding.pry
#     each_object_status(response_in_json, 'list', 'active')
#   end
# end

shared_examples 'creates object with active status' do |model, parameters|
  it 'creates active object', type: :request do
    case model
    when 'user'
      post '/api/users', { user: parameters }, 'HTTP_AUTHORIZATION' => key
    when 'list'
      post "/api/users/#{user.id}/lists", { list: parameters }, 'HTTP_AUTHORIZATION' => key
    end
    object = Object.const_get(model.capitalize)
    this_object = object.first
    expect(this_object.status).to eq('active')
  end
end

shared_examples 'destroy archives object' do |model|
  it 'object status becomes archived', type: :request do
    case model
    when 'user'
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
    when 'list'
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
    end
    object = Object.const_get(model.capitalize)
    this_object = object.first
    expect(this_object.status).to eq('archived')
  end
end

shared_examples 'destroy archives object dependents' do |model, dependent, number|
  it 'dependents become archived', type: :request do
    object = ''
    if dependent == 'api_key'
      object = ApiKey
    else
      object = Object.const_get(dependent.capitalize)
    end
    dependents = object.where(status: 0).all
    expect(dependents.length).to eq(number)
    case model
    when 'user'
      delete "/api/users/#{@user_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
    when 'list'
      delete "/api/users/#{user.id}/lists/#{@list_destroy.id}", nil, 'HTTP_AUTHORIZATION' => key
    end
    dependents = object.where(status: 0).all
    expect(dependents.length).to eq(0)
  end
end

shared_examples 'create object status active' do |model, parameters|
  it 'makes object active', type: :controller do
    case model
    when 'user'
      post :create, user: parameters
    when 'list'
      post :create, user_id: user.id, list: parameters
    when 'item'
      post :create, list_id: list.id, item: parameters
    end
    object = Object.const_get(model.capitalize)
    this_object = object.first
    expect(this_object.status).to eq('active')
  end
end

shared_examples 'destroy action archives object' do |model|
  it 'makes object active', type: :controller do
    case model
    when 'user'
      delete :destroy, id: @user_destroy.id
    when 'list'
      delete :destroy, user_id: user.id, id: @list_destroy.id
    end
    object = Object.const_get(model.capitalize)
    this_object = object.first
    expect(this_object.status).to eq('archived')
  end
end

shared_examples 'destroy action archives object dependents' do |model, dependent, number|
  it 'dependents become archived', type: :controller do
    object = ''
    if dependent == 'api_key'
      object = ApiKey
    else
      object = Object.const_get(dependent.capitalize)
    end
    dependents = object.where(status: 0).all
    expect(dependents.length).to eq(number)
    case model
    when 'user'
      delete :destroy, id: @user_destroy.id
    when 'list'
      delete :destroy, user_id: user.id, id: @list_destroy.id
    end
    dependents = object.where(status: 0).all
    expect(dependents.length).to eq(0)
  end
end

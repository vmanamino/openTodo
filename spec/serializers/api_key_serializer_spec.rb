require 'rails_helper'

describe ApiKeySerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:api_key) { create(api_key) }
  let(:api_key_json) { ApiKeySerializer.new(api_key).to_json }
  
end
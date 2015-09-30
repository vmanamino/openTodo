require 'rails_helper'

describe ApiKeySerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key) }
  let(:api_key_json) { ApiKeySerializer.new(api_key).to_json }
  context 'Attributes' do
    before do
      @api_key_json = JSON.parse(api_key_json)
    end
    it 'json access token equals object access token' do
      expect(@api_key_json['api_key']['access_token']).to eq(api_key.access_token)
    end
    it 'json contains expires_at attribute' do
      expect(@api_key_json['api_key'].key?('expires_at')).to be true
    end
    it 'json expires_at attribute has value' do
      expect(@api_key_json['api_key']['expires_at']).not_to be nil
    end
    it 'json excludes user' do
      expect(@api_key_json['api_key']['user_id']).to be nil
    end
  end
end

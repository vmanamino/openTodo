require 'rails_helper'

describe UserSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:user_json) { UserSerializer.new(user).to_json }
  context 'Attributes' do
    before do
      @user_obj = JSON.parse(user_json)
    end
    it 'id equals User id' do
      expect(@user_obj['user']['id']).to eq(user.id)
    end
    it 'username equals User username' do
      expect(@user_obj['user']['username']).to eq(user.username)
    end
  end
end

require 'rails_helper'

describe ListSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:list) { create(:list, user: user) }
  let(:list_json) { ListSerializer.new(list).to_json }
  context 'Attributes' do
    before do
      @list_obj = JSON.parse(list_json)
    end
    it 'id equals List id' do
      expect(@list_obj['list']['id']).to eq(list.id)
    end
    it 'user_id equals User id' do
      expect(@list_obj['list']['user_id']).to eq(list.user_id)
    end
  end
end

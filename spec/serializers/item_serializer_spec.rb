require 'rails_helper'

describe ItemSerializer, type: :serializer do
  let(:list) { create(:list) }
  let(:item) { create(:item, list_id: list.id) }
  let(:item_json) { ItemSerializer.new(item).to_json }
  context 'Attributes' do
    before do
      @item_obj = JSON.parse(item_json)
    end
    it 'id equals Item id' do
      expect(@item_obj['item']['id']).to eq(item.id)
    end
    it 'list_id equals List id' do
      expect(@item_obj['item']['list_id']).to eq(list.id)
    end
    it 'name equals Item name' do
      expect(@item_obj['item']['name']).to eq(item.name)
    end
    it 'done is set to false by default' do
      expect(@item_obj['item']['done']).to be false
    end
  end
end

require 'rails_helper'

describe Item do
  before do
    @item = create(:item)
  end
  it { should belong_to(:list) }
  it { should validate_presence_of(:name) }
  it { should_not allow_value(nil).for(:done) }
  it { should validate_inclusion_of(:done).in_array([true, false]) }
  describe '.owned' do
    before do
      @owner = create(:user)
      @list_other = create(:list)
      @list_owned = create(:list, user: @owner)
      @items_other = create_list(:item, 5, list: @list_other)
      @items_owned = create_list(:item, 5, list: @list_owned)
    end
    it 'collects all items associated with a user\'s list' do
      items_owned = Item.owned(@owner)
      expect(items_owned.length).to eq(5)
      counter = 0
      while counter < items_owned.length
        expect(items_owned[counter].user.id).to eq(@owner.id)
        counter += 1
      end
    end
  end
end

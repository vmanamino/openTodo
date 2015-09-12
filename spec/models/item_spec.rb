require 'rails_helper'

describe Item do
  before do
    @item = create(:item)
  end
  it { should belong_to(:list) }
  it { should validate_presence_of(:name) }
  it { should_not allow_value(nil).for(:done) }
  it { should validate_inclusion_of(:done).in_array([true, false]) }
end

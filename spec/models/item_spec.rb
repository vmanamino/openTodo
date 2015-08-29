require 'rails_helper'

describe Item do
  before do
    @item = create(:item)
  end
  it { should belong_to(:list) }
  it { should validate_presence_of(:name) }
end

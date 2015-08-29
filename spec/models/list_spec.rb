require 'rails_helper'

describe List do
  before do
    @list = create(:list)
  end
  it { should have_many(:items) }
  it { should belong_to(:user) }
end

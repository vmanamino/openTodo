require 'rails_helper'

describe List do
  before do
    @list = create(:list)
  end
  it { should have_many(:items).dependent(:destroy) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:permissions) }
  describe '.defaults' do
    it 'sets permissions to public when list is created' do
      new_list = create(:list)
      expect(new_list.permissions).to eq('public')
    end
    it 'sets permissions only when no value manually entered' do
      private_list = create(:list, permissions: 'private')
      expect(private_list.permissions).to eq('private')
    end
  end
end

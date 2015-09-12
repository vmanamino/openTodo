require 'rails_helper'

describe List do
  before do
    @list = create(:list)
  end
  it { should have_many(:items).dependent(:destroy) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:name) }
  it { should validate_inclusion_of(:permissions).in_array(%w( viewable private open )) }
  it 'Invalidate permissions' do
    expect(List.new(permissions: 'other string')).not_to be_valid
  end
  it 'Invalidation messages' do
    invalid_list = List.new(permissions: 'other string')
    invalid_list.valid?
    expect(invalid_list.errors.full_messages[0]).to eq('Name can\'t be blank')
    expect(invalid_list.errors.full_messages[1]).to eq('Permissions is not included in the list')
  end
  describe '.defaults' do
    it 'sets permissions to public when list is created' do
      new_list = create(:list)
      expect(new_list.permissions).to eq('viewable')
    end
    it 'sets to \'public\' only when no value manually entered' do
      private_list = create(:list, permissions: 'private')
      expect(private_list.permissions).to eq('private')
    end
  end
end

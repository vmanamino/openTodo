require 'rails_helper'

describe List do
  let(:user) { create(:user) }
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
  describe '.visible_to' do
    before do
      @lists_own = create_list(:list, 5, user: user)
      @lists_other = create_list(:list, 5)
    end
    it 'collects all lists which reference user in scope' do
      lists = List.visible_to(user)
      expect(lists.length).to eq(5)
      counter = 0
      while counter < lists.length
        expect(lists[counter].user_id).to eq(user.id)
        counter += 1
      end
    end
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

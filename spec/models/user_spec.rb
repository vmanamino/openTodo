require 'rails_helper'

describe User do
  before do
    @user = create(:user)
  end
  it { should have_many(:lists).dependent(:destroy) }
  it { should have_many(:api_keys).dependent(:destroy) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:password) }
  it { should define_enum_for(:status) }
  describe '.lists_archived' do
    before do
      @list_dependent = create(:list, user: @user)
      @items_dependent = create_list(:item, 5, list: @list_dependent)
    end
    it 'archives list dependent when self becomes archived' do
      lists = List.where(status: 0).all
      expect(lists.length).to eq(1)
      @user.archived!
      lists = List.where(status: 0).all
      expect(lists.length).to eq(0)
      lists.each do |list|
        expect(list.status).to eq('archived')
      end
    end
    it 'archives item children of dependent list' do
      items = Item.where(status: 0).all
      expect(items.length).to eq(5)
      @user.archived!
      items = Item.where(status: 0).all
      expect(items.length).to eq(0)
      items.each do |item|
        expect(item.status).to eq('archived')
      end
    end
  end
  describe '.keys_archived' do
    before do
      @api_keys = create_list(:api_key, 5, user: @user)
    end
    it 'archives api keys when self archived' do
      keys = ApiKey.where(status: 0).all
      expect(keys.length).to eq(5)
      @user.archived!
      keys = ApiKey.where(status: 0).all
      expect(keys.length).to eq(0)
      keys.each do |key|
        expect(key.status).to eq('archived')
      end
    end
  end
end

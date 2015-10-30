class Item < ActiveRecord::Base
  include Enums

  belongs_to :list

  validates :name, presence: true
  validates :done, inclusion: { in: [true, false] }, allow_nil: false

  after_initialize :defaults, if: :new_record?

  def self.owned(user) # rubocop:disable Metrics/MethodLength
    items_owned = []
    owned_lists = List.where('user_id=? AND status=?', user.id, 0).all
    counter = 0
    while counter < owned_lists.length
      items = Item.where(list_id: owned_lists[counter].id)
      items.each do |item|
        items_owned.push(item)
      end
      counter += 1
    end
    items_owned
  end

  def user
    list = self.list
    user = list.user
    user
  end

  private

  def defaults
    self.done ||= false
  end
end

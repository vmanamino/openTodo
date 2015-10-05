class Item < ActiveRecord::Base
  belongs_to :list

  validates :name, presence: true
  validates :done, inclusion: { in: [true, false] }, allow_nil: false

  after_initialize :defaults, if: :new_record?

  def self.owned(user)
    items_owned = []
    owned_lists = List.where(user_id: user.id).all
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
    return user
  end

  private

  def defaults
    self.done ||= false
  end
end

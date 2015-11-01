class List < ActiveRecord::Base
  include Enums

  scope :visible_to, -> (user) { active.where(user_id: user.id) }

  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  validates :permissions, inclusion: %w( viewable private open ), allow_nil: false

  after_update :items_archived
  after_initialize :defaults, if: :new_record?

  private

  def items_archived
    return false unless self.status == 'archived' # rubocop:disable Style/RedundantSelf
    items = Item.active.where(list_id: self).all
    items.each do |item| # rubocop:disable Style/SymbolProc
      item.archived!
    end
  end

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'viewable'
  end
end

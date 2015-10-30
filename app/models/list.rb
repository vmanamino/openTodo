class List < ActiveRecord::Base
  include Enums

  scope :visible_to, -> (user) { where('user_id=? AND status=?', user.id, 0) }

  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  validates :permissions, inclusion: %w( viewable private open ), allow_nil: false

  after_update :items_archived
  after_initialize :defaults, if: :new_record?

  private

  def items_archived
    return false unless self.status == 'archived' # rubocop:disable Style/RedundantSelf
    items = Item.where('list_id=? AND status=?', self, 0).all
    items.each do |item| # rubocop:disable Style/SymbolProc
      item.archived!
    end
  end

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'viewable'
  end
end

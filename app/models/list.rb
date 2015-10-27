class List < ActiveRecord::Base
  extend ActiveModel::Callbacks
  scope :visible_to, -> (user) { where('user_id=? AND status=?', user.id, 0) }

  enum status: [:active, :archived]
  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  validates :permissions, inclusion: %w( viewable private open ), allow_nil: false

  # define_model_callbacks :archived, only: [:after]
  after_update :items_archived
  after_initialize :defaults, if: :new_record?

  private

  def items_archived
    if self.status == 'archived'
      items = Item.where('list_id=? AND status=?', self, 0).all
      items.each do |item|
        item.archived!
      end
    end
  end

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'viewable'
  end
end

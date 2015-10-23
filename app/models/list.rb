class List < ActiveRecord::Base
  scope :visible_to, -> (user) { where(user_id: user.id) }

  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  validates :permissions, inclusion: %w( viewable private open ), allow_nil: false

  after_initialize :defaults, if: :new_record?

  private

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'viewable'
  end
end

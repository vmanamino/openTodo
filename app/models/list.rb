class List < ActiveRecord::Base
  scope :visible_to, -> (user) { where(user_id: user.id) }

  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  # validates_inclusion_of :permissions, in: %w( viewable private open ), allow_nil: false
  validates :permissions, inclusion: %w( viewable private open ), allow_nil: false

  after_initialize :defaults, if: :new_record?

#   def self.visible_to(user)
#     lists = []
#     if user
#       lists = List.where('user_id=? OR permissions!=?', user.id, 'private')
#     end
#     lists
#   end

  private

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'viewable'
  end
end

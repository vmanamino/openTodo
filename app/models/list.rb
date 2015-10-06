class List < ActiveRecord::Base
  scope :visible_to, -> (user) { where(user_id: user.id) }

  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  # validates_inclusion_of :permissions, in: %w( viewable private open ), allow_nil: false
  validates :permissions, inclusion: %w( viewable private open ), allow_nil: false

  after_initialize :defaults, if: :new_record?

  def self.own(id, user)
    list = ''
    if user
      list = List.where('id=? AND user_id=?', id, user.id).first
    end
    list
  end

  private

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'viewable'
  end
end

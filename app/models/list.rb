class List < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy

  validates :name, presence: true
  validates_inclusion_of :permissions, in: %w( public private ), allow_nil: false

  after_initialize :defaults, if: :new_record?

  private

  def defaults
    # self.name ||= 'my list'
    self.permissions ||= 'public'
  end
end

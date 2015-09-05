class List < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy

  after_initialize :defaults, if: :new_record?

  private

  def defaults
    self.permissions ||= 'public'
  end
end

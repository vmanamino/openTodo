class Item < ActiveRecord::Base
  belongs_to :list

  validates :name, presence: true
  validates :done, inclusion: { in: [true, false] }, allow_nil: false

  after_initialize :defaults, if: :new_record?

  private

  def defaults
    self.done ||= false
  end

end

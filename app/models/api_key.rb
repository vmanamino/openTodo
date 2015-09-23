class ApiKey < ActiveRecord::Base
  belongs_to :user

  validate :expires_at_is_time

  before_create :generate_access_token
  after_initialize :defaults, if: :new_record?

  def expires_at_is_time
    errors.add(:expires_at, 'Must be a valid time value') unless expires_at.is_a?(Time)
  end

  private

  def generate_access_token
    number = 0
    begin
      self.access_token = SecureRandom.hex
      number += 1
    end while self.class.exists?(access_token: access_token) && number == 1 # rubocop:disable Lint/Loop
  end

  def defaults
    self.expires_at ||= 1.day.from_now
  end
end

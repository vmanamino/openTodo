class ApiKey < ActiveRecord::Base
  belongs_to :user

  validate :expires_at_is_time

  before_create :generate_access_token
  after_initialize :defaults, if: :new_record?

  def expires_at_is_time
    if !expires_at.is_a?(Time)
      errors.add(:expires_at, 'Must be a valid time value')
    end
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def defaults
    self.expires_at ||= 1.day.from_now
  end
end

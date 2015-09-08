class User < ActiveRecord::Base
  has_many :lists, dependent: :destroy
  validates :username, presence: true
  validates :password, presence: true
end

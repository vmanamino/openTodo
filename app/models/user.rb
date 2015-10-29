class User < ActiveRecord::Base
  include Enums

  has_many :lists, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  validates :username, presence: true
  validates :password, presence: true

  after_update :lists_archived
  after_update :keys_archived

  private

  def lists_archived
    if self.status == 'archived'
      lists = List.where('user_id=? AND status=?', self, 0).all
      lists.each do |list|
        list.archived!
      end
    end
  end

  def keys_archived
    if self.status == 'archived'
      keys = ApiKey.where('user_id=? AND status=?', self, 0).all
      keys.each do |key|
        key.archived!
      end
    end
  end
end

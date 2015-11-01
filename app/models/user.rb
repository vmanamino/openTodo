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
    return false unless self.status == 'archived' # rubocop:disable Style/RedundantSelf
    lists = List.active.where(user_id: self).all
    lists.each do |list| # rubocop:disable Style/SymbolProc
      list.archived!
    end
  end

  def keys_archived
    return false unless self.status == 'archived' # rubocop:disable Style/RedundantSelf
    keys = ApiKey.active.where(user_id: self).all
    keys.each do |key| # rubocop:disable Style/SymbolProc
      key.archived!
    end
  end
end

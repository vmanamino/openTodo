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
    lists = List.where('user_id=? AND status=?', self, 0).all
    lists.each do |list| # rubocop:disable Style/SymbolProc
      list.archived!
    end
  end

  def keys_archived
    return false unless self.status == 'archived' # rubocop:disable Style/RedundantSelf
    keys = ApiKey.where('user_id=? AND status=?', self, 0).all
    keys.each do |key| # rubocop:disable Style/SymbolProc
      key.archived!
    end
  end
end

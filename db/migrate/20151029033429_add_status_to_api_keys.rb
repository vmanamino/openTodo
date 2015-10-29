class AddStatusToApiKeys < ActiveRecord::Migration
  def change
    add_column :api_keys, :status, :integer, default: 0
  end
end

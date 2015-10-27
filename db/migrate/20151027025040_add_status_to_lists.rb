class AddStatusToLists < ActiveRecord::Migration
  def change
    add_column :lists, :status, :integer, default: 0
  end
end

class AddPermissionsToLists < ActiveRecord::Migration
  def change
    add_column :lists, :permissions, :string
  end
end

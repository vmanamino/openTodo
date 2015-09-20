class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :access_token
      t.datetime :expires_at
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :api_keys, :access_token, unique: true
  end
end

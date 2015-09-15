class ChangeRememberTokenToDigest < ActiveRecord::Migration
  def change
    remove_index  :users, column: :remember_token
    rename_column :users, :remember_token, :remember_digest
  end
end

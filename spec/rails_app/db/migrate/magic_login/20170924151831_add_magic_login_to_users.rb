class AddMagicLoginToUsers < ActiveRecord::CompatibleLegacyMigration.migration_class
  def self.up
    add_column :users, :magic_login_token, :string, default: nil
    add_column :users, :magic_login_token_expires_at, :datetime, default: nil
    add_column :users, :magic_login_email_sent_at, :datetime, default: nil

    add_index :users, :magic_login_token
  end

  def self.down
    remove_index :users, :magic_login_token

    remove_column :users, :magic_login_token
    remove_column :users, :magic_login_token_expires_at
    remove_column :users, :magic_login_email_sent_at
  end
end

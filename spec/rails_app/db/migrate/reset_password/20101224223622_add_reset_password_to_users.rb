class AddResetPasswordToUsers < ActiveRecord::CompatibleLegacyMigration.migration_class
  def self.up
    add_column :users, :reset_password_token, :string, default: nil
    add_column :users, :reset_password_token_expires_at, :datetime, default: nil
    add_column :users, :reset_password_email_sent_at, :datetime, default: nil
    add_column :users, :access_count_to_reset_password_page, :integer, default: 0
  end

  def self.down
    remove_column :users, :reset_password_email_sent_at
    remove_column :users, :reset_password_token_expires_at
    remove_column :users, :reset_password_token
    remove_column :users, :access_count_to_reset_password_page
  end
end

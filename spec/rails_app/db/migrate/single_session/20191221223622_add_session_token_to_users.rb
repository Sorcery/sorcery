class AddSessionTokenToUsers < ActiveRecord::CompatibleLegacyMigration.migration_class
  def change
    add_column :users, :session_token, :string, default: nil
  end
end

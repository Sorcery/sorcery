class SorceryBruteForceProtection < <%= migration_class_name %>
  def change
    add_column :<%= tableized_model_class %>, :failed_logins_count, :integer, default: 0
    add_column :<%= tableized_model_class %>, :lock_expires_at, :datetime, default: nil
    add_column :<%= tableized_model_class %>, :unlock_token, :string, default: nil

    add_index :<%= tableized_model_class %>, :unlock_token
  end
end

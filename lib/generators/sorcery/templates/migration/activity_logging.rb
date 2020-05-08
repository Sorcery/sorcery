class SorceryActivityLogging < <%= migration_class_name %>
  def change
    add_column :<%= tableized_model_class %>, :last_login_at,     :datetime, default: nil
    add_column :<%= tableized_model_class %>, :last_logout_at,    :datetime, default: nil
    add_column :<%= tableized_model_class %>, :last_activity_at,  :datetime, default: nil
    add_column :<%= tableized_model_class %>, :last_login_from_ip_address, :string, default: nil

    add_index :<%= tableized_model_class %>, [:last_logout_at, :last_activity_at]
  end
end

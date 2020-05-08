class SorceryRememberMe < <%= migration_class_name %>
  def change
    add_column :<%= tableized_model_class %>, :remember_me_token, :string, default: nil
    add_column :<%= tableized_model_class %>, :remember_me_token_expires_at, :datetime, default: nil

    add_index :<%= tableized_model_class %>, :remember_me_token
  end
end

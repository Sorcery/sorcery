class SorceryMagicLogin < <%= migration_class_name %>
  def change
    add_column :<%= tableized_model_class %>, :magic_login_token, :string, default: nil
    add_column :<%= tableized_model_class %>, :magic_login_token_expires_at, :datetime, default: nil
    add_column :<%= tableized_model_class %>, :magic_login_email_sent_at, :datetime, default: nil

    add_index :<%= tableized_model_class %>, :magic_login_token
  end
end

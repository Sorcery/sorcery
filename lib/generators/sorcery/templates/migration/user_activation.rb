class SorceryUserActivation < <%= migration_class_name %>
  def change
    add_column :<%= tableized_model_class %>, :activation_state, :string, default: nil
    add_column :<%= tableized_model_class %>, :activation_token, :string, default: nil
    add_column :<%= tableized_model_class %>, :activation_token_expires_at, :datetime, default: nil

    add_index :<%= tableized_model_class %>, :activation_token
  end
end

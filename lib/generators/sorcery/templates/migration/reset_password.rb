class SorceryResetPassword < <%= migration_class_name %>
  def change
    add_column :<%= model_class_name.tableize %>, :reset_password_token, :string, default: nil
    add_column :<%= model_class_name.tableize %>, :reset_password_token_expires_at, :datetime, default: nil
    add_column :<%= model_class_name.tableize %>, :reset_password_email_sent_at, :datetime, default: nil
    add_column :<%= model_class_name.tableize %>, :access_count_to_reset_password_page, :integer, default: 0

    add_index :<%= model_class_name.tableize %>, :reset_password_token
  end
end

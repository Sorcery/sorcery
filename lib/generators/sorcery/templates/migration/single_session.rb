class SorcerySingleSession < <%= migration_class_name %>
  def change
    add_column :<%= model_class_name.tableize %>, :session_token, :string, default: nil
  end
end

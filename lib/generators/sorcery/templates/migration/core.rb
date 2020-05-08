class SorceryCore < <%= migration_class_name %>
  def change
    create_table :<%= tableized_model_class %> do |t|
      t.string :email,            null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps                null: false
    end

    add_index :<%= tableized_model_class %>, :email, unique: true
  end
end

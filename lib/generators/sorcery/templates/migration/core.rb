class SorceryCore < <%= migration_class_name %>
  def change
    create_table :<%= tableized_model_class %> do |t|
      t.string :email,            null: false, index: { unique: true }
      t.string :crypted_password
      t.string :salt

      t.timestamps                null: false
    end
  end
end

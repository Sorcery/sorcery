class SorceryCore < <%= migration_class_name %>
  def change
    create_table :<%= model_class_name.tableize %> do |t|
      t.string :email,            :null => false
      t.string :username
      t.string :crypted_password
      t.string :salt

      t.timestamps                :null => false
    end

    add_index :<%= model_class_name.tableize %>, :email, unique: true
    add_index :<%= model_class_name.tableize %>, :username, unique: true

  end
end

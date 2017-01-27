class CreateUsers < ActiveRecord::CompatibleLegacyMigration.migration_class
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :email,            null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end

  def self.down
    drop_table :users
  end
end

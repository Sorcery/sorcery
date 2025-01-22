class MigrationHelper
  class << self
    def migrate(path)
      ActiveRecord::MigrationContext.new(path).migrate
    end

    def rollback(path)
      ActiveRecord::MigrationContext.new(path).rollback
    end

    # private
    # Commenting out as this is not needed. Was causing error due to deprecation of .connection superseded by
    # .with_connection. Removed schema_migration from new(path, schema_migrations) since it is optional
    # and all test now passing with rails 7.2.
    # def schema_migration
    #  ActiveRecord::Base.connection.schema_migration
    # end
  end
end

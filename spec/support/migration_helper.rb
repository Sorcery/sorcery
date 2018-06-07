class MigrationHelper
  class << self
    def migrate(path)
      if Rails.gem_version >= Gem::Version.new('5.2.0')
        ActiveRecord::MigrationContext.new(path).migrate
      else
        MigrationHelper.migrate(path)
      end
    end

    def rollback(path)
      if Rails.gem_version >= Gem::Version.new('5.2.0')
        ActiveRecord::MigrationContext.new(path).rollback
      else
        MigrationHelper.rollback(path)
      end
    end
  end
end

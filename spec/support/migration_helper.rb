# frozen_string_literal: true

class MigrationHelper
  class << self
    def migrate(path)
      ActiveRecord::MigrationContext.new(path).migrate
    end

    def rollback(path)
      ActiveRecord::MigrationContext.new(path).rollback
    end
  end
end

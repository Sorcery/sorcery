module Sorcery
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new(nil, 'Sorcery')
  end
end

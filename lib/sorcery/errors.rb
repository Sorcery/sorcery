# frozen_string_literal: true

module Sorcery
  ##
  # Custom error class for rescuing from all Sorcery errors.
  #
  class Error < StandardError; end

  module Errors
    class InvalidCredentials < Sorcery::Error; end
  end
end

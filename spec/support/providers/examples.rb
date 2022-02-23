# frozen_string_literal: true

require 'sorcery/providers/base'

module Sorcery
  module Providers
    class Examples < Base
      include Protocols::Oauth2
    end
  end
end

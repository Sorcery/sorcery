require 'argon2'

module Sorcery
  module CryptoProviders
    class Argon2
      class << self
        # Setting the option :pepper implements a keyed Argon2 algorithm.
        attr_accessor :pepper
        # This is the :cost option for the Argon2 library.
        # The higher the cost the more secure it is and the longer is take the generate a hash. By default this is 16.
        # Set this to whatever you want, play around with it to get that perfect balance between
        # security and performance.
        def cost
          @cost ||= 16
        end
        attr_writer :cost
        alias stretches cost
        alias stretches= cost=

        # Creates a hash for the password passed
        def encrypt(*tokens)
          hasher = ::Argon2::Password.new(m_cost: cost, secret: pepper)
          hasher.create(join_tokens(tokens))
        end

        # Does the hash match the tokens? Uses the same tokens that were used to encrypt.
        def matches?(hash, *tokens)
          return false if hash.nil? || hash == {}
          ::Argon2::Password.verify_password(join_tokens(tokens), hash, pepper)
        end

        # This method is used as a flag to tell Sorcery to "resave" the password
        # upon a successful login, using the new cost
        def cost_matches?(hash)
          hashcost = /m=(\d+),/.match hash
          raise "cost_matches? not called with a valid hash" unless hashcost
          return (hashcost[1].to_i == 1 << cost)
        end

        def reset!
          @cost = 16
          @pepper = nil
        end

        private

        def join_tokens(tokens)
          tokens.flatten.join
        end

      end
    end
  end
end

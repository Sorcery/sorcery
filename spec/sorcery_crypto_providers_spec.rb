require 'spec_helper'

describe 'Crypto Providers wrappers' do
  describe Sorcery::CryptoProviders::MD5 do
    after do
      described_class.reset!
    end

    it 'encrypt works via wrapper like normal lib' do
      expect(described_class.encrypt('Noam Ben-Ari')).to eq Digest::MD5.hexdigest('Noam Ben-Ari')
    end

    it 'works with multiple stretches' do
      described_class.stretches = 3
      expect(described_class.encrypt('Noam Ben-Ari')).to eq Digest::MD5.hexdigest(Digest::MD5.hexdigest(Digest::MD5.hexdigest('Noam Ben-Ari')))
    end

    it 'matches? returns true when matches' do
      expect(described_class.matches?(Digest::MD5.hexdigest('Noam Ben-Ari'), 'Noam Ben-Ari')).to be true
    end

    it 'matches? returns false when no match' do
      expect(described_class.matches?(Digest::MD5.hexdigest('Noam Ben-Ari'), 'Some Dude')).to be false
    end
  end

  describe Sorcery::CryptoProviders::SHA1 do
    before(:all) do
      @digest = 'Noam Ben-Ari'
      described_class.stretches.times { @digest = Digest::SHA1.hexdigest(@digest) }
    end

    after do
      described_class.reset!
    end

    it 'encrypt works via wrapper like normal lib' do
      expect(described_class.encrypt('Noam Ben-Ari')).to eq @digest
    end

    it 'works with multiple stretches' do
      described_class.stretches = 3
      expect(described_class.encrypt('Noam Ben-Ari')).to eq Digest::SHA1.hexdigest(Digest::SHA1.hexdigest(Digest::SHA1.hexdigest('Noam Ben-Ari')))
    end

    it 'matches? returns true when matches' do
      expect(described_class.matches?(@digest, 'Noam Ben-Ari')).to be true
    end

    it 'matches? returns false when no match' do
      expect(described_class.matches?(@digest, 'Some Dude')).to be false
    end

    it 'matches password encrypted using salt and join token from upstream' do
      described_class.join_token = 'test'
      expect(described_class.encrypt(%w[password gq18WBnJYNh2arkC1kgH])).to eq '894b5bf1643b8d0e1b2eaddb22426be7036dab70'
    end
  end

  describe Sorcery::CryptoProviders::SHA256 do
    before(:all) do
      @digest = 'Noam Ben-Ari'
      described_class.stretches.times { @digest = Digest::SHA256.hexdigest(@digest) }
    end

    after do
      described_class.reset!
    end

    it 'encrypt works via wrapper like normal lib' do
      expect(described_class.encrypt('Noam Ben-Ari')).to eq @digest
    end

    it 'works with multiple stretches' do
      described_class.stretches = 3
      expect(described_class.encrypt('Noam Ben-Ari')).to eq Digest::SHA256.hexdigest(Digest::SHA256.hexdigest(Digest::SHA256.hexdigest('Noam Ben-Ari')))
    end

    it 'matches? returns true when matches' do
      expect(described_class.matches?(@digest, 'Noam Ben-Ari')).to be true
    end

    it 'matches? returns false when no match' do
      expect(described_class.matches?(@digest, 'Some Dude')).to be false
    end
  end

  describe Sorcery::CryptoProviders::SHA512 do
    before(:all) do
      @digest = 'Noam Ben-Ari'
      described_class.stretches.times { @digest = Digest::SHA512.hexdigest(@digest) }
    end

    after do
      described_class.reset!
    end

    it 'encrypt works via wrapper like normal lib' do
      expect(described_class.encrypt('Noam Ben-Ari')).to eq @digest
    end

    it 'works with multiple stretches' do
      described_class.stretches = 3
      expect(described_class.encrypt('Noam Ben-Ari')).to eq Digest::SHA512.hexdigest(Digest::SHA512.hexdigest(Digest::SHA512.hexdigest('Noam Ben-Ari')))
    end

    it 'matches? returns true when matches' do
      expect(described_class.matches?(@digest, 'Noam Ben-Ari')).to be true
    end

    it 'matches? returns false when no match' do
      expect(described_class.matches?(@digest, 'Some Dude')).to be false
    end
  end

  describe Sorcery::CryptoProviders::AES256 do
    before(:all) do
      aes = OpenSSL::Cipher.new('AES-256-ECB')
      aes.encrypt
      @key = 'asd234dfs423fddsmndsflktsdf32343'
      aes.key = @key
      @digest = 'Noam Ben-Ari'
      @digest = [aes.update(@digest) + aes.final].pack('m').chomp
      described_class.key = @key
    end

    it 'encrypt works via wrapper like normal lib' do
      expect(described_class.encrypt('Noam Ben-Ari')).to eq @digest
    end

    it 'matches? returns true when matches' do
      expect(described_class.matches?(@digest, 'Noam Ben-Ari')).to be true
    end

    it 'matches? returns false when no match' do
      expect(described_class.matches?(@digest, 'Some Dude')).to be false
    end

    it 'can be decrypted' do
      aes = OpenSSL::Cipher.new('AES-256-ECB')
      aes.decrypt
      aes.key = @key
      expect(aes.update(@digest.unpack1('m')) + aes.final).to eq 'Noam Ben-Ari'
    end
  end

  describe Sorcery::CryptoProviders::BCrypt do
    before(:all) do
      described_class.cost = 1
      @digest = BCrypt::Password.create('Noam Ben-Ari', cost: described_class.cost)
      @tokens = %w[password gq18WBnJYNh2arkC1kgH]
    end

    after do
      described_class.reset!
    end

    it 'is comparable with original secret' do
      expect(BCrypt::Password.new(described_class.encrypt('Noam Ben-Ari'))).to eq 'Noam Ben-Ari'
    end

    it 'works with multiple costs' do
      described_class.cost = 3
      expect(BCrypt::Password.new(described_class.encrypt('Noam Ben-Ari'))).to eq 'Noam Ben-Ari'
    end

    it 'matches? returns true when matches' do
      expect(described_class.matches?(@digest, 'Noam Ben-Ari')).to be true
    end

    it 'matches? returns false when no match' do
      expect(described_class.matches?(@digest, 'Some Dude')).to be false
    end

    it 'respond_to?(:stretches) returns true' do
      expect(described_class.respond_to?(:stretches)).to be true
    end

    it 'sets cost when stretches is set' do
      described_class.stretches = 4

      # stubbed in Sorcery::TestHelpers::Internal
      expect(described_class.cost).to eq 1
    end

    it 'matches token encrypted with salt from upstream' do
      # NOTE: actual comparison is done by BCrypt::Password#==(raw_token)
      expect(described_class.encrypt(@tokens)).to eq @tokens.join
    end

    it 'respond_to?(:pepper) returns true' do
      expect(described_class.respond_to?(:pepper)).to be true
    end

    context 'when pepper is provided' do
      before do
        described_class.pepper = 'pepper'
        @digest = described_class.encrypt(@tokens) # a BCrypt::Password object
      end

      it 'matches token encrypted with salt and pepper from upstream' do
        # NOTE: actual comparison is done by BCrypt::Password#==(raw_token)
        expect(@digest).to eq @tokens.join.concat('pepper')
      end

      it 'matches? returns true when matches' do
        expect(described_class.matches?(@digest, *@tokens)).to be true
      end

      it 'matches? returns false when pepper is replaced with empty string' do
        described_class.pepper = ''
        expect(described_class.matches?(@digest, *@tokens)).to be false
      end

      it 'matches? returns false when no match' do
        expect(described_class.matches?(@digest, 'a_random_incorrect_password')).to be false
      end
    end

    context 'when pepper is an empty string (default)' do
      before do
        described_class.pepper = ''
        @digest = described_class.encrypt(@tokens) # a BCrypt::Password object
      end

      # make sure the default pepper '' does nothing
      it 'matches token encrypted with salt only (without pepper)' do
        expect(@digest).to eq @tokens.join # keep consistency with the older versions of #join_token
      end

      it 'matches? returns true when matches' do
        expect(described_class.matches?(@digest, *@tokens)).to be true
      end

      it 'matches? returns false when pepper has changed' do
        described_class.pepper = 'a new pepper'
        expect(described_class.matches?(@digest, *@tokens)).to be false
      end

      it 'matches? returns false when no match' do
        expect(described_class.matches?(@digest, 'a_random_incorrect_password')).to be false
      end
    end
  end
end

require 'spec_helper'

describe Sorcery::Model::TemporaryToken do
  describe '.generate_random_token' do
    subject { described_class.generate_random_token.length }

    before do
      sorcery_reload!
    end

    context 'when token_randomness is 3' do
      before do
        sorcery_model_property_set(:token_randomness, 3)
      end

      it { is_expected.to eq 4 }
    end

    context 'when token_randomness is 15' do
      before do
        sorcery_model_property_set(:token_randomness, 15)
      end

      it { is_expected.to eq 20 }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'sorcery/providers/base'

describe Sorcery::Providers::Example do
  before(:all) do
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:example])
  end

  context 'fetching a single-word custom provider' do
    it 'returns the provider' do
      expect(Sorcery::Controller::Config.example).to be_a(Sorcery::Providers::Example)
    end
  end
end

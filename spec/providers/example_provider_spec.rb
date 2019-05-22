# frozen_string_literal: true

require 'spec_helper'
require 'sorcery/providers/base'

describe Sorcery::Providers::ExampleProvider do
  before(:all) do
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:example_provider])
  end

  context 'fetching a multi-word custom provider' do
    it 'returns the provider' do
      expect(Sorcery::Controller::Config.example_provider).to be_a(Sorcery::Providers::ExampleProvider)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'sorcery/providers/base'

describe Sorcery::Providers::Examples do
  before(:all) do
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:examples])
  end

  context 'fetching a plural custom provider' do
    it 'returns the provider' do
      expect(Sorcery::Controller::Config.examples).to be_a(Sorcery::Providers::Examples)
    end
  end
end

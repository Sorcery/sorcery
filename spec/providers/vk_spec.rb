require 'spec_helper'
require 'sorcery/providers/base'
require 'sorcery/providers/vk'
require 'webmock/rspec'

describe Sorcery::Providers::Vk do
  include WebMock::API

  let(:provider) { Sorcery::Controller::Config.vk }

  before(:all) do
    sorcery_reload!([:external])
    sorcery_controller_property_set(:external_providers, [:vk])
    sorcery_controller_external_property_set(:vk, :key, 'KEY')
    sorcery_controller_external_property_set(:vk, :secret, 'SECRET')
  end

  def stub_vk_authorize
    stub_request(:post, %r{https\:\/\/oauth\.vk\.com\/access_token}).to_return(
      status: 200,
      body: '{"access_token":"TOKEN","expires_in":86329,"user_id":1}',
      headers: { 'content-type' => 'application/json' }
    )
  end

  context 'getting user info hash' do
    it 'should provide VK API version' do
      stub_vk_authorize
      sorcery_controller_external_property_set(:vk, :api_version, '5.71')

      get_user = stub_request(
        :get,
        'https://api.vk.com/method/getProfiles?access_token=TOKEN&fields=&scope=email&uids=1&v=5.71'
      ).to_return(body: '{"response":[{"id":1}]}')

      token = provider.process_callback({ code: 'CODE' }, nil)
      provider.get_user_hash(token)

      expect(get_user).to have_been_requested
    end
  end
end

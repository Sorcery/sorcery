shared_examples_for 'rails_single_session_model' do
  # ----------------- PLUGIN CONFIGURATION -----------------------
  let(:user) { create_new_user }

  describe 'loaded plugin configuration' do
    before(:all) do
      sorcery_reload!([:single_session])
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    context 'API' do
      specify { expect(user).to respond_to :session_token }

      specify { expect(user).to respond_to :regenerate_session_token }
    end

    it "allows configuration option 'session_token_attribute_name'" do
      sorcery_model_property_set(:session_token_attribute_name, :random_token)

      expect(User.sorcery_config.session_token_attribute_name).to eq :random_token
    end
  end

  describe 'when activated with sorcery' do
    before(:all) do
      sorcery_reload!([:single_session])
    end

    describe '#regenerate_session_token' do
      it 'generates and updates user record with new random session token' do
        expect(user.session_token).to be_nil

        token = user.regenerate_session_token

        expect(user.session_token).to eq token
      end
    end
  end
end

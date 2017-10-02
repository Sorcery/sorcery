shared_examples_for "magic_login_model" do
  let(:user) {create_new_user}
  before(:each) do
    User.sorcery_adapter.delete_all
  end
  
  context 'loaded plugin configuration' do
    let(:config) {User.sorcery_config}
    
    before(:all) do
      sorcery_reload!([:magic_login])
    end
    
    after(:each) do
      User.sorcery_config.reset!
    end
    
    describe "enables configuration options" do
      it  do
        sorcery_model_property_set(:magic_login_token_attribute_name, :test_magic_login_token)
        expect(config.magic_login_token_attribute_name).to eq :test_magic_login_token
      end
      
      it do
        sorcery_model_property_set(:magic_login_token_expires_at_attribute_name, :test_magic_login_token_expires_at)
        expect(config.magic_login_token_expires_at_attribute_name).to eq :test_magic_login_token_expires_at
      end
      
      it do
        sorcery_model_property_set(:magic_login_email_sent_at_attribute_name, :test_magic_login_email_sent_at)
        expect(config.magic_login_email_sent_at_attribute_name).to eq :test_magic_login_email_sent_at
      end
      
      it do
        TestMailerClass = Class.new # need a mailer class to test
        sorcery_model_property_set(:magic_login_mailer_class, TestMailerClass)
        expect(config.magic_login_mailer_class).to eq TestMailerClass
      end
      
      it do
        sorcery_model_property_set(:magic_login_mailer_disabled, false)
        expect(config.magic_login_mailer_disabled).to eq false
      end
      
      it do
        sorcery_model_property_set(:magic_login_email_method_name, :test_magic_login_email)
        expect(config.magic_login_email_method_name).to eq :test_magic_login_email
      end
      
      it do
        sorcery_model_property_set(:magic_login_expiration_period, 100000000)
        expect(config.magic_login_expiration_period).to eq 100000000
      end
      
      it do
        sorcery_model_property_set(:magic_login_time_between_emails, 100000000)
        expect(config.magic_login_time_between_emails).to eq 100000000
      end
    end

    describe "#generate_magic_login_token!" do
      context "magic_login_token is nil" do
        it do
          token_before = user.magic_login_token
          user.generate_magic_login_token!
          expect(user.magic_login_token).not_to eq token_before
          expect(user.magic_login_token_expires_at).not_to be_nil
          expect(user.magic_login_email_sent_at).not_to be_nil
        end
      end
      
      context "magic_login_token is not nil" do
        it "changes `user.magic_login_token`" do
          token_before = user.magic_login_token
          user.generate_magic_login_token!
          expect(user.magic_login_token).not_to eq token_before
        end
      end
    end
  end
end

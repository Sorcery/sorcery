shared_examples_for 'magic_login_model' do
  let(:user) { create_new_user }
  before(:each) do
    User.sorcery_adapter.delete_all
  end

  context 'loaded plugin configuration' do
    let(:config) { User.sorcery_config }

    before(:all) do
      sorcery_reload!([:magic_login])
    end

    after(:each) do
      User.sorcery_config.reset!
    end

    describe 'enables configuration options' do
      it do
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
        sorcery_model_property_set(:magic_login_expiration_period, 100_000_000)
        expect(config.magic_login_expiration_period).to eq 100_000_000
      end

      it do
        sorcery_model_property_set(:magic_login_time_between_emails, 100_000_000)
        expect(config.magic_login_time_between_emails).to eq 100_000_000
      end
    end

    describe '#generate_magic_login_token!' do
      context 'magic_login_token is nil' do
        it "magic_login_token_expires_at and magic_login_email_sent_at aren't nil " do
          user.generate_magic_login_token!
          expect(user.magic_login_token_expires_at).not_to be_nil
          expect(user.magic_login_email_sent_at).not_to be_nil
        end

        it 'magic_login_token is different from the one before' do
          token_before = user.magic_login_token
          user.generate_magic_login_token!
          expect(user.magic_login_token).not_to eq token_before
        end
      end

      context 'magic_login_token is not nil' do
        it 'changes `user.magic_login_token`' do
          token_before = user.magic_login_token
          user.generate_magic_login_token!
          expect(user.magic_login_token).not_to eq token_before
        end
      end
    end

    describe '#deliver_magic_login_instructions!' do
      context 'success' do
        before do
          sorcery_model_property_set(:magic_login_time_between_emails, 30 * 60)
          sorcery_model_property_set(:magic_login_mailer_disabled, false)
          Timecop.travel(10.days.ago) do
            user.send(:"#{config.magic_login_email_sent_at_attribute_name}=", DateTime.now)
          end
          sorcery_model_property_set(:magic_login_mailer_class, ::SorceryMailer)
        end

        it do
          user.deliver_magic_login_instructions!
          expect(ActionMailer::Base.deliveries.size).to eq 1
        end

        it do
          expect(user.deliver_magic_login_instructions!).to eq true
        end
      end

      context 'failure' do
        context 'magic_login_time_between_emails is nil' do
          it 'returns false' do
            sorcery_model_property_set(:magic_login_time_between_emails, nil)
            expect(user.deliver_magic_login_instructions!).to eq false
          end
        end

        context 'magic_login_email_sent_at is nil' do
          it 'returns false' do
            user.send(:"#{config.magic_login_email_sent_at_attribute_name}=", nil)
            expect(user.deliver_magic_login_instructions!).to eq false
          end
        end

        context 'now is before magic_login_email_sent_at plus the interval' do
          it 'returns false' do
            user.send(:"#{config.magic_login_email_sent_at_attribute_name}=", DateTime.now)
            sorcery_model_property_set(:magic_login_time_between_emails, 30 * 60)
            expect(user.deliver_magic_login_instructions!).to eq false
          end
        end

        context 'magic_login_mailer_disabled is true' do
          it 'returns false' do
            sorcery_model_property_set(:magic_login_mailer_disabled, true)
            expect(user.deliver_magic_login_instructions!).to eq false
          end
        end
      end
    end

    describe '#clear_magic_login_token!' do
      it 'makes magic_login_token_attribute_name and magic_login_token_expires_at_attribute_name nil' do
        user.magic_login_token = 'test_token'
        user.magic_login_token_expires_at = Time.now

        user.clear_magic_login_token!

        expect(user.magic_login_token).to eq nil
        expect(user.magic_login_token_expires_at).to eq nil
      end
    end
  end
end

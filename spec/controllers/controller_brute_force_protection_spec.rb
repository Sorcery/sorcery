require 'spec_helper'

describe SorceryController, type: :controller do
  let!(:user) { User.create!(username: 'test_user', email: 'bla@example.com', password: 'password') }

  def request_test_login
    get :test_login, params: { email: 'bla@example.com', password: 'blabla' }
  end

  # ----------------- BRUTE FORCE PROTECTION -----------------------
  describe 'brute force protection features' do
    before(:all) do
      MigrationHelper.migrate("#{Rails.root}/db/migrate/brute_force_protection")
      sorcery_reload!([:brute_force_protection])
    end

    after(:all) do
      MigrationHelper.rollback("#{Rails.root}/db/migrate/brute_force_protection")
    end

    it 'counts login retries' do
      allow(User).to receive(:authenticate).and_yield(nil, :other)
      allow(User.sorcery_adapter).to receive(:find_by_credentials).with(['bla@example.com', 'blabla']).and_return(user)

      expect(user).to receive(:register_failed_login!).exactly(3).times

      3.times { request_test_login }
    end

    it 'resets the counter on a good login' do
      # Set failed_logins_count to a non-zero value first
      user.update!(failed_logins_count: 3)

      allow(User).to receive(:authenticate).and_yield(user, nil)

      get :test_login, params: { email: 'bla@example.com', password: 'secret' }

      user.reload
      expect(user.failed_logins_count).to eq(0)
    end

    it 'calls after_login_lock when user locked' do
      user.update!(failed_logins_count: 2)
      sorcery_model_property_set(:consecutive_login_retries_amount_limit, 2)

      expect(controller).to receive(:after_login_lock!).once
      request_test_login
    end
  end
end

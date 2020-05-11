require 'spec_helper'

describe SorceryController, type: :controller do
  let(:user) { double('user', id: 42, email: 'bla@bla.com') }

  describe 'with jwt auth features' do
    before(:all) do
      sorcery_reload!([:jwt])
    end

    before do
      sorcery_controller_property_set(:jwt_algorithm, 'HS256')
      sorcery_controller_property_set(:jwt_encode_key, 'secret_key')
      sorcery_controller_property_set(:jwt_decode_key, 'secret_key')
      sorcery_controller_property_set(:jwt_lifetime, 600)
      sorcery_controller_property_set(:jwt_lifetime_leeway, 10)
      sorcery_controller_property_set(:jwt_header, 'Authorization')
      sorcery_controller_property_set(:jwt_additional_user_payload_action, nil)

      # TODO: dirty hack, fix this
      allow(subject).to receive(:register_last_activity_time_to_db)
    end

    describe '#require_jwt_authentication' do
      before do
        sorcery_controller_property_set(:jwt_not_authenticated_action, :test_not_authenticated_action)
      end

      it 'triggers auto-login attempts via the call to logged_in?' do
        expect(subject).to receive(:logged_in?).and_call_original

        get :test_jwt_auth
      end

      context 'when login succeeds' do
        before do
          allow(subject).to receive(:logged_in?).and_return(true)
        end

        it 'does not call not_authenticated_action' do
          expect(subject).not_to receive(:test_not_authenticated_action)

          get :test_jwt_auth
        end
      end

      context 'when login fails' do
        before do
          allow(subject).to receive(:logged_in?).and_return(false)
        end

        it 'calls not_authenticated_action' do
          expect(subject).to receive(:test_not_authenticated_action).and_call_original

          get :test_jwt_auth
        end
      end
    end

    describe '#jwt_authenticate' do
      let(:other_user) { double('user', id: 31, email: 'user@bla.com') }

      it 'validates jwt configuration' do
        expect(subject).to receive(:validate_jwt_configuration)

        subject.jwt_authenticate('bla@bla.com', 'secret')
      end

      context 'when succeeds' do
        before do
          allow(User).to receive(:authenticate).with('bla@bla.com', 'secret') do |&block|
            block.call(user, nil)
            # simulate authentication_response response_value
            user
          end
          allow(subject).to receive(:generate_jwt).and_return({ token: 'token', payload: {} })
          allow(user).to receive(:email=)
        end

        it 'returns hash with jwt token' do
          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }

          expect(assigns[:result]).to eq({ token: 'token', payload: {}})
        end

        it 'updates current user' do
          # simulate situation when other user is logged in
          subject.auto_login(other_user)
          expect(subject.current_user).to eq(other_user)

          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }

          expect(subject.current_user).to eq(user)
        end

        it 'calls block' do
          expect(user).to receive(:email=).with('some@email.com')

          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }
        end

        it 'runs after_login callbacks' do
          expect(subject).to receive(:after_login!).with(user, %w[bla@bla.com secret])

          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }
        end
      end

      context 'when fails' do
        before do
          allow(User).to receive(:authenticate).with('bla@bla.com', 'secret') do |&block|
            block.call(nil, :invalid_login)
            # simulate authentication_response response_value
            false
          end
        end

        it 'returns nil' do
          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }

          expect(assigns[:result]).to be_nil
        end

        it 'updates current user' do
          # simulate situation when other user is logged in
          subject.auto_login(other_user)
          expect(subject.current_user).to eq(other_user)

          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }

          expect(subject.current_user).to be_nil
        end

        it 'calls block' do
          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }

          expect(assigns[:error]).to eq(:invalid_login)
        end

        it 'runs after_failed_login callbacks' do
          expect(subject).to receive(:after_failed_login!).with(%w[bla@bla.com secret])

          get :test_jwt_login, params: { email: 'bla@bla.com', password: 'secret' }
        end
      end
    end

    describe '#generate_jwt' do
      # Number of seconds - 1_589_100_200
      let(:current_time) { Time.new(2020, 5, 10, 11, 43, 20) }
      let(:expected_payload) do
        { sub: 42,
          iat: 1_589_100_200,
          exp: 1_589_100_800,
          email: 'bla@bla.com' }
      end

      before do
        sorcery_controller_property_set(:jwt_additional_user_payload_action, :jwt_custom_payload)
        Timecop.freeze(current_time)
      end
      after { Timecop.return }

      it 'returns hash with token and payload' do
        expect(subject).to receive(:jwt_encode).with(expected_payload).and_return('token')
        expect(user).to receive(:jwt_custom_payload).and_return({ email: 'bla@bla.com' })

        jwt = subject.generate_jwt(user)

        expect(jwt[:token]).to eq('token')
        expect(jwt[:payload]).to eq(expected_payload)
      end
    end

    describe '#login_from_jwt_header' do
      let(:other_user) { double('user', id: 31, email: 'user@bla.com') }

      before do
        # simulate situation when other user is logged in
        subject.auto_login(other_user)
        expect(subject.current_user).to eq(other_user)
      end

      context 'jwt is present in header and correctly decoded' do
        before do
          allow(subject).to receive(:jwt_decoded_payload).and_return({ 'sub' => 42 })
        end

        it 'updates current user' do
          expect(User.sorcery_adapter).to receive(:find_by_id).with(42).and_return(user)

          subject.login_from_jwt_header

          expect(subject.current_user).to eq(user)
        end
      end

      context 'jwt is missing or incorrect' do
        before do
          allow(subject).to receive(:jwt_decoded_payload).and_return({})
        end

        it 'updates current user' do
          expect(User.sorcery_adapter).not_to receive(:find_by_id)

          subject.login_from_jwt_header

          expect(subject.current_user).to be_nil
        end
      end
    end

    describe '#jwt_not_authenticated' do
      it 'returns unauthorized header' do
        expect(subject).to receive(:head).with(:unauthorized).and_return('HTTP/1.1 401 Unauthorized')

        expect(subject.jwt_not_authenticated).to eq('HTTP/1.1 401 Unauthorized')
      end
    end

    describe '#validate_jwt_configuration' do
      context 'configuration is valid' do
        it 'does not raise any exceptions' do
          expect { subject.validate_jwt_configuration }.not_to raise_error
        end
      end

      context 'jwt_algorithm is missing' do
        before { sorcery_controller_property_set(:jwt_algorithm, '') }

        it 'raises an exception' do
          expect { subject.validate_jwt_configuration }.to raise_error(ArgumentError)
        end
      end

      context 'jwt_encode_key is missing' do
        before { sorcery_controller_property_set(:jwt_encode_key, '') }

        it 'raises an exception' do
          expect { subject.validate_jwt_configuration }.to raise_error(ArgumentError)
        end
      end

      context 'jwt_decode_key is missing' do
        before { sorcery_controller_property_set(:jwt_decode_key, '') }

        it 'raises an exception' do
          expect { subject.validate_jwt_configuration }.to raise_error(ArgumentError)
        end
      end
    end

    describe '#jwt_from_header' do
      context 'token is present without type' do
        before { request.headers['Authorization'] = 'token' }

        it 'returns token' do
          expect(subject.jwt_from_header).to eq('token')
        end
      end

      context 'token is present with Token type' do
        before { request.headers['Authorization'] = 'Token token' }

        it 'returns token' do
          expect(subject.jwt_from_header).to eq('token')
        end
      end

      context 'token is present with Bearer type' do
        before { request.headers['Authorization'] = 'Bearer token' }

        it 'returns token' do
          expect(subject.jwt_from_header).to eq('token')
        end
      end

      context 'token is present with invalid type' do
        before { request.headers['Authorization'] = 'Some token' }

        it 'returns full header as token' do
          expect(subject.jwt_from_header).to eq('Some token')
        end
      end

      context 'token is missing' do
        before { request.headers['Authorization'] = nil }

        it 'returns empty string' do
          expect(subject.jwt_from_header).to eq('')
        end
      end

      context 'header is missing' do
        it 'returns empty string' do
          expect(subject.jwt_from_header).to eq('')
        end
      end
    end

    describe '#jwt_decoded_payload' do
      it 'returns decoded payload from token stored in header' do
        expect(subject).to receive(:jwt_from_header).and_return('token')
        expect(subject).to receive(:jwt_decode).with('token').and_return({ 'sub' => 1 })
        expect(subject.jwt_decoded_payload).to eq({ 'sub' => 1 })
      end
    end

    describe 'jwt encoding and decoding' do
      # Number of seconds - 1_589_100_200
      let(:current_time) { Time.new(2020, 5, 10, 11, 43, 20) }
      # token valid for 10 minutes
      let(:payload) do
        { 'sub' => 42,
          'iat' => 1_589_100_200,
          'exp' => 1_589_100_800 }
      end
      let(:plain_text_key) { 'secret_key' }
      # generated using OpenSSL::PKey::RSA.generate(2048)
      let(:rsa_private_key) do
        <<~PRIVATEKEY
          -----BEGIN RSA PRIVATE KEY-----
          MIIEowIBAAKCAQEAng2jkht0lZa6kvReXTj5mPirDb41Sm48cBySIeGZhr/WDQLf
          SvzC8vLXCatx0OwIWT4uYvLbpsVXjJFgb3eIJ/9hWdf/1BeSw9FMtbXg5kvy7+iz
          aMgl6sssTCqc7sLgh5BQ6hclN3ivuZH8mBOaWjPQXXed4zd4DrtKCN0ObrMz7jDT
          zYG/PN9Iy6SWeKhvPzIp397Na6b6c91ZHjYr+Ueo0PDcWkeAsJXy8SilNCYNajLh
          jWbb9sY94PQ6+j49OpvfUvc1utjcE76Jl9MCqiuhpD49VRPYngyBWdniDWhvnkst
          mReBteFmgrsyTnLCDFYwgAAx6XO9zdyS4yS3CwIDAQABAoIBAElfW4gAZubqykJe
          X1A3mueAySfgHS0ob7Y8DTrdWEBN3ji8FJzjKj1OrrU2eefbKyUC0NXumDmbc0E2
          W+ZjPzoSPEdRFtqG9wMgrtPMU1OV/nmRNXh3MeMF3tKdFa1hmopUXLvPct+Fj04+
          j1yp/QXS9+/sD8fjgECWgZALzx9kJvDgHfFJjPPD/UKr7g3yc+Qiqw7km/Ix5D+G
          ZhagDDQ1o9j02rAH4hi6qmsBbeLlyyt/Ainm+FZcVPR5aftw55ipdJW2M1BXKrXg
          HQkWBYoswcIeIxucA02DUjWA/X5b4It2Kru+oGO1iAZIjVFctwkuvbdEs8PD4JgF
          lxOfH4ECgYEAzZ8bhATm9s0I2JkUkI58DbcqZIqxpKwlZbxh+4/ccgmLqczUBJnI
          fOTeJRDTJm3Q+lCvfzAF3AnxMZe24G1b0OxYrD9ZdC4fbVKQOlQB04SXvbdJa62E
          gUbkYmuRvM0gJWu2YSQ8i7mIUQ2Nry5fovO1rSShysSpyZzPCF3ArhMCgYEAxMb6
          zKRCNfs9Ws1x7VQwzu46ISM7NETgPUMjigJZs9eetqn4uytNyhn3ME+S4RYArXFX
          YTZ2DPB+ygqD+v01mWTN5GRfAnQzYdrfH1OLDZ9Dr0tmia4Hk043ImybDX6JmEnz
          UxIo4I9Qkhfw9yklKJr31I5OWzmXofeDfCw2kikCgYEApWyM4YBkJEg+BqvZTJcl
          HI+wrmSamEXabGfLWGybyK7/SqM8K1thXYFvatiHV1JgHxIMrsF+5VCmV+SbvyCc
          DpAmoqTwnbSBmh0jZZmyQm5Y+ctcaSGXCb5z/O5XuFI6u4BVoP9bKnogPj0uMLKZ
          RGrXTa278HqZslbShQOQATsCgYAKFR/4qFn0JiFoq6owvOWbVL2JwSJhdT4AJZaG
          lcQ+4MdzGJZ0EK31swrlYM5n1hbGzE3r3zyBQTld5NgKXjsG1xFtqG7t00Jmuy4/
          jqpLUmPHcZeZal9c/t74VpRDRr6KHQ/oq7+Icg9wzOU95M/QmtAkBf6h0fuhAuur
          yyAosQKBgC7QP7/yV+bNVZO0rsiApKwVlSSGu6T7unUUOnJsTyl17tFCkU3cn/1E
          1OrilgLt77O4yeQaJf9KUgFLcNVIU3gyhf4BIX2m7t5Z4rYzqIdt4OcxpvaU5x9J
          taaOtqVlt4Sblou0UP178lNPe6ODc6GLteGgHGvJz6fKRN5T3757
          -----END RSA PRIVATE KEY-----
        PRIVATEKEY
      end
      let(:rsa_public_key) do
        <<~PUBLICKEY
          -----BEGIN PUBLIC KEY-----
          MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAng2jkht0lZa6kvReXTj5
          mPirDb41Sm48cBySIeGZhr/WDQLfSvzC8vLXCatx0OwIWT4uYvLbpsVXjJFgb3eI
          J/9hWdf/1BeSw9FMtbXg5kvy7+izaMgl6sssTCqc7sLgh5BQ6hclN3ivuZH8mBOa
          WjPQXXed4zd4DrtKCN0ObrMz7jDTzYG/PN9Iy6SWeKhvPzIp397Na6b6c91ZHjYr
          +Ueo0PDcWkeAsJXy8SilNCYNajLhjWbb9sY94PQ6+j49OpvfUvc1utjcE76Jl9MC
          qiuhpD49VRPYngyBWdniDWhvnkstmReBteFmgrsyTnLCDFYwgAAx6XO9zdyS4yS3
          CwIDAQAB
          -----END PUBLIC KEY-----
        PUBLICKEY
      end

      describe '#jwt_encode' do
        context 'password-based algorithm' do
          before do
            sorcery_controller_property_set(:jwt_encode_key, plain_text_key)
            sorcery_controller_property_set(:jwt_algorithm, 'HS256')
          end

          it 'returns token' do
            expect(subject.jwt_encode(payload)).to eq('eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOjQyLCJpYXQiOjE1ODkxMDAyMDAsImV4cCI6MTU4OTEwMDgwMH0.nPWyXQzqJqkMTMGuEzWtkeXN2BpVYecr3Lmpd99MJhY')
          end
        end

        context 'key-based algorithm' do
          before do
            sorcery_controller_property_set(:jwt_encode_key, OpenSSL::PKey.read(rsa_private_key))
            sorcery_controller_property_set(:jwt_algorithm, 'RS256')
          end

          it 'returns token' do
            expect(subject.jwt_encode(payload)).to eq('eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjQyLCJpYXQiOjE1ODkxMDAyMDAsImV4cCI6MTU4OTEwMDgwMH0.E69mTt7gKJHN_QXD5YfFYA4CdQKMYVDotNkzekN62WYurpNynEQGz1W6PABTSLCPQPTFXmUDgzvc1JedQ3MQtpcKSbaowxiQBh0_wHwPca9hzQDZH8tBiujcYemY5URJRZUOO9d3izHpAg35GcODQays0cnK1ianshp9nLzExogKv0e5WMXHlCaH7Hxw2gNaTKO5S_qKeE0J-6WMk1FbSYCgBfSmVnf1lx9LNKkF0l_dejZEBVczzVAK5agbbTiG6yunzewKpBwGcVR4CGG2Xbsh6Ey3SwoOqygrrosxMP3d_DlfUntKKLwn6O2p7jGqnYGGZj8MMe7UKQN8X65dxQ')
          end
        end
      end

      describe '#jwt_decode' do
        context 'password-based algorithm' do
          let(:token) { 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOjQyLCJpYXQiOjE1ODkxMDAyMDAsImV4cCI6MTU4OTEwMDgwMH0.nPWyXQzqJqkMTMGuEzWtkeXN2BpVYecr3Lmpd99MJhY' }

          before do
            sorcery_controller_property_set(:jwt_decode_key, plain_text_key)
            sorcery_controller_property_set(:jwt_algorithm, 'HS256')
          end

          context 'token has not expired' do
            before { Timecop.freeze(current_time) }
            after { Timecop.return }

            it 'returns payload' do
              expect(subject.jwt_decode(token)).to eq(payload)
            end
          end

          context 'token has expired' do
            before { Timecop.freeze(current_time + 11.minutes) }
            after { Timecop.return }

            it 'returns empty hash' do
              expect(subject.jwt_decode(token)).to eq({})
            end
          end

          context 'token is within leeway' do
            before do
              Timecop.freeze(current_time + 11.minutes)
              # token is valid for 10 minutes, we are 11 minutes ahead, so adding 61 second
              sorcery_controller_property_set(:jwt_lifetime_leeway, 61)
            end
            after { Timecop.return }

            it 'returns payload' do
              expect(subject.jwt_decode(token)).to eq(payload)
            end
          end
        end

        context 'key-based algorithm' do
          let(:token) { 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjQyLCJpYXQiOjE1ODkxMDAyMDAsImV4cCI6MTU4OTEwMDgwMH0.E69mTt7gKJHN_QXD5YfFYA4CdQKMYVDotNkzekN62WYurpNynEQGz1W6PABTSLCPQPTFXmUDgzvc1JedQ3MQtpcKSbaowxiQBh0_wHwPca9hzQDZH8tBiujcYemY5URJRZUOO9d3izHpAg35GcODQays0cnK1ianshp9nLzExogKv0e5WMXHlCaH7Hxw2gNaTKO5S_qKeE0J-6WMk1FbSYCgBfSmVnf1lx9LNKkF0l_dejZEBVczzVAK5agbbTiG6yunzewKpBwGcVR4CGG2Xbsh6Ey3SwoOqygrrosxMP3d_DlfUntKKLwn6O2p7jGqnYGGZj8MMe7UKQN8X65dxQ' }

          before do
            sorcery_controller_property_set(:jwt_decode_key, OpenSSL::PKey.read(rsa_public_key))
            sorcery_controller_property_set(:jwt_algorithm, 'RS256')
          end

          context 'token has not expired' do
            before { Timecop.freeze(current_time) }
            after { Timecop.return }

            it 'returns payload' do
              expect(subject.jwt_decode(token)).to eq(payload)
            end
          end

          context 'token has expired' do
            before { Timecop.freeze(current_time + 11.minutes) }
            after { Timecop.return }

            it 'returns empty hash' do
              expect(subject.jwt_decode(token)).to eq({})
            end
          end

          context 'token is within leeway' do
            before do
              Timecop.freeze(current_time + 11.minutes)
              # token is valid for 10 minutes, we are 11 minutes ahead, so adding 61 second
              sorcery_controller_property_set(:jwt_lifetime_leeway, 61)
            end
            after { Timecop.return }

            it 'returns payload' do
              expect(subject.jwt_decode(token)).to eq(payload)
            end
          end
        end
      end
    end
  end
end

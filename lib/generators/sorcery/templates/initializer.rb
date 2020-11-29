# The first thing you need to configure is which modules you need in your app.
# The default is nothing which will include only core features (password encryption, login/logout).
#
# Available submodules are: :user_activation, :http_basic_auth, :remember_me,
# :reset_password, :session_timeout, :brute_force_protection, :activity_logging,
# :magic_login, :external
Rails.application.config.sorcery.submodules = []

# Here you can configure each submodule's features.
Rails.application.config.sorcery.configure do |config|
  # -- core --
  # What controller action to call for non-authenticated users. You can also
  # override the 'not_authenticated' method of course.
  # Default: `:not_authenticated`
  #
  # config.not_authenticated_action =

  # When a non logged-in user tries to enter a page that requires login, save
  # the URL he wants to reach, and send him there after login, using 'redirect_back_or_to'.
  # Default: `true`
  #
  # config.save_return_to_url =

  # Set domain option for cookies; Useful for remember_me submodule.
  # Default: `nil`
  #
  # config.cookie_domain =

  # Allow the remember_me cookie to be set through AJAX
  # Default: `true`
  #
  # config.remember_me_httponly =

  # Set token randomness. (e.g. user activation tokens)
  # The length of the result string is about 4/3 of `token_randomness`.
  # Default: `15`
  #
  # config.token_randomness =

  # -- session timeout --
  # How long in seconds to keep the session alive.
  # Default: `3600`
  #
  # config.session_timeout =

  # Use the last action as the beginning of session timeout.
  # Default: `false`
  #
  # config.session_timeout_from_last_action =

  # Invalidate active sessions. Requires an `invalidate_sessions_before` timestamp column
  # Default: `false`
  #
  # config.session_timeout_invalidate_active_sessions_enabled =

  # -- http_basic_auth --
  # What realm to display for which controller name. For example {"My App" => "Application"}
  # Default: `{"application" => "Application"}`
  #
  # config.controller_to_realm_map =

  # -- activity logging --
  # Will register the time of last user login, every login.
  # Default: `true`
  #
  # config.register_login_time =

  # Will register the time of last user logout, every logout.
  # Default: `true`
  #
  # config.register_logout_time =

  # Will register the time of last user action, every action.
  # Default: `true`
  #
  # config.register_last_activity_time =

  # -- external --
  # What providers are supported by this app
  # i.e. [:twitter, :facebook, :github, :linkedin, :xing, :google, :liveid, :salesforce, :slack, :line].
  # Default: `[]`
  #
  # config.external_providers =

  # You can change it by your local ca_file. i.e. '/etc/pki/tls/certs/ca-bundle.crt'
  # Path to ca_file. By default use a internal ca-bundle.crt.
  # Default: `'path/to/ca_file'`
  #
  # config.ca_file =

  # Linkedin requires r_emailaddress scope to fetch user's email address.
  # You can skip including the email field if you use an intermediary signup form. (using build_from method).
  # The r_emailaddress scope is only necessary if you are using the create_from method directly.
  #
  # config.linkedin.key = ""
  # config.linkedin.secret = ""
  # config.linkedin.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=linkedin"
  # config.linkedin.user_info_mapping = {
  #   first_name: 'localizedFirstName',
  #   last_name:  'localizedLastName',
  #   email:      'emailAddress'
  # }
  # config.linkedin.scope = "r_liteprofile r_emailaddress"
  #
  #
  # For information about XING API:
  # - user info fields go to https://dev.xing.com/docs/get/users/me
  #
  # config.xing.key = ""
  # config.xing.secret = ""
  # config.xing.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=xing"
  # config.xing.user_info_mapping = {first_name: "first_name", last_name: "last_name"}
  #
  #
  # Twitter will not accept any requests nor redirect uri containing localhost,
  # Make sure you use 0.0.0.0:3000 to access your app in development
  #
  # config.twitter.key = ""
  # config.twitter.secret = ""
  # config.twitter.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=twitter"
  # config.twitter.user_info_mapping = {:email => "screen_name"}
  #
  # config.facebook.key = ""
  # config.facebook.secret = ""
  # config.facebook.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=facebook"
  # config.facebook.user_info_path = "me?fields=email"
  # config.facebook.user_info_mapping = {:email => "email"}
  # config.facebook.access_permissions = ["email"]
  # config.facebook.display = "page"
  # config.facebook.api_version = "v2.3"
  # config.facebook.parse = :json
  #
  # config.instagram.key = ""
  # config.instagram.secret = ""
  # config.instagram.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=instagram"
  # config.instagram.user_info_mapping = {:email => "username"}
  # config.instagram.access_permissions = ["basic", "public_content", "follower_list", "comments", "relationships", "likes"]
  #
  # config.github.key = ""
  # config.github.secret = ""
  # config.github.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=github"
  # config.github.user_info_mapping = {:email => "name"}
  # config.github.scope = ""
  #
  # config.paypal.key = ""
  # config.paypal.secret = ""
  # config.paypal.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=paypal"
  # config.paypal.user_info_mapping = {:email => "email"}
  #
  # config.wechat.key = ""
  # config.wechat.secret = ""
  # config.wechat.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=wechat"
  #
  # For Auth0, site is required and should match the domain provided by Auth0.
  #
  # config.auth0.key = ""
  # config.auth0.secret = ""
  # config.auth0.callback_url = "https://0.0.0.0:3000/oauth/callback?provider=auth0"
  # config.auth0.site = "https://example.auth0.com"
  #
  # config.google.key = ""
  # config.google.secret = ""
  # config.google.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=google"
  # config.google.user_info_mapping = {:email => "email", :username => "name"}
  # config.google.scope = "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile"
  #
  # For Microsoft Graph, the key will be your App ID, and the secret will be your app password/public key.
  # The callback URL "can't contain a query string or invalid special characters"
  # See: https://docs.microsoft.com/en-us/azure/active-directory/active-directory-v2-limitations#restrictions-on-redirect-uris
  # More information at https://graph.microsoft.io/en-us/docs
  #
  # config.microsoft.key = ""
  # config.microsoft.secret = ""
  # config.microsoft.callback_url = "http://0.0.0.0:3000/oauth/callback/microsoft"
  # config.microsoft.user_info_mapping = {:email => "userPrincipalName", :username => "displayName"}
  # config.microsoft.scope = "openid email https://graph.microsoft.com/User.Read"
  #
  # config.vk.key = ""
  # config.vk.secret = ""
  # config.vk.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=vk"
  # config.vk.user_info_mapping = {:login => "domain", :name => "full_name"}
  # config.vk.api_version = "5.71"
  #
  # config.slack.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=slack"
  # config.slack.key = ''
  # config.slack.secret = ''
  # config.slack.user_info_mapping = {email: 'email'}
  #
  # To use liveid in development mode you have to replace mydomain.com with
  # a valid domain even in development. To use a valid domain in development
  # simply add your domain in your /etc/hosts file in front of 127.0.0.1
  #
  # config.liveid.key = ""
  # config.liveid.secret = ""
  # config.liveid.callback_url = "http://mydomain.com:3000/oauth/callback?provider=liveid"
  # config.liveid.user_info_mapping = {:username => "name"}

  # For information about JIRA API:
  # https://developer.atlassian.com/display/JIRADEV/JIRA+REST+API+Example+-+OAuth+authentication
  # To obtain the consumer key and the public key you can use the jira-ruby gem https://github.com/sumoheavy/jira-ruby
  # or run openssl req -x509 -nodes -newkey rsa:1024 -sha1 -keyout rsakey.pem -out rsacert.pem to obtain the public key
  # Make sure you have configured the application link properly

  # config.jira.key = "1234567"
  # config.jira.secret = "jiraTest"
  # config.jira.site = "http://localhost:2990/jira/plugins/servlet/oauth"
  # config.jira.signature_method =  "RSA-SHA1"
  # config.jira.private_key_file = "rsakey.pem"

  # For information about Salesforce API:
  # https://developer.salesforce.com/signup &
  # https://www.salesforce.com/us/developer/docs/api_rest/
  # Salesforce callback_url must be https. You can run the following to generate self-signed ssl cert:
  # openssl req -new -newkey rsa:2048 -sha1 -days 365 -nodes -x509 -keyout server.key -out server.crt
  # Make sure you have configured the application link properly
  # config.salesforce.key = '123123'
  # config.salesforce.secret = 'acb123'
  # config.salesforce.callback_url = "https://127.0.0.1:9292/oauth/callback?provider=salesforce"
  # config.salesforce.scope = "full"
  # config.salesforce.user_info_mapping = {:email => "email"}

  # config.line.key = ""
  # config.line.secret = ""
  # config.line.callback_url = "http://mydomain.com:3000/oauth/callback?provider=line"
  # config.line.scope = "profile"
  # config.line.bot_prompt = "normal"
  # config.line.user_info_mapping = {name: 'displayName'}

  
  # For information about Discord API
  # https://discordapp.com/developers/docs/topics/oauth2
  # config.discord.key = "xxxxxx"
  # config.discord.secret = "xxxxxx"
  # config.discord.callback_url = "http://localhost:3000/oauth/callback?provider=discord"
  # config.discord.scope = "email guilds"

  # For information about Battlenet API
  # https://develop.battle.net/documentation/guides/using-oauth
  # config.battlenet.site = "https://eu.battle.net/" #See Website for other Regional Domains
  # config.battlenet.key = "xxxxxx"
  # config.battlenet.secret = "xxxxxx"
  # config.battlenet.callback_url = "http://localhost:3000/oauth/callback?provider=battlenet"
  # config.battlenet.scope = "openid"
  # --- user config ---
  config.user_config do |user|
    # -- core --
    # Specify username attributes, for example: [:username, :email].
    # Default: `[:email]`
    #
    # user.username_attribute_names =

    # Change *virtual* password attribute, the one which is used until an encrypted one is generated.
    # Default: `:password`
    #
    # user.password_attribute_name =

    # Downcase the username before trying to authenticate, default is false
    # Default: `false`
    #
    # user.downcase_username_before_authenticating =

    # Change default email attribute.
    # Default: `:email`
    #
    # user.email_attribute_name =

    # Change default crypted_password attribute.
    # Default: `:crypted_password`
    #
    # user.crypted_password_attribute_name =

    # What pattern to use to join the password with the salt
    # Default: `""`
    #
    # user.salt_join_token =

    # Change default salt attribute.
    # Default: `:salt`
    #
    # user.salt_attribute_name =

    # How many times to apply encryption to the password.
    # Default: 1 in test env, `nil` otherwise
    #
    user.stretches = 1 if Rails.env.test?

    # Encryption key used to encrypt reversible encryptions such as AES256.
    # WARNING: If used for users' passwords, changing this key will leave passwords undecryptable!
    # Default: `nil`
    #
    # user.encryption_key =

    # Use an external encryption class.
    # Default: `nil`
    #
    # user.custom_encryption_provider =

    # Encryption algorithm name. See 'encryption_algorithm=' for available options.
    # Default: `:bcrypt`
    #
    # user.encryption_algorithm =

    # Make this configuration inheritable for subclasses. Useful for ActiveRecord's STI.
    # Default: `false`
    #
    # user.subclasses_inherit_config =

    # -- remember_me --
    # How long in seconds the session length will be
    # Default: `60 * 60 * 24 * 7`
    #
    # user.remember_me_for =

    # When true, sorcery will persist a single remember me token for all
    # logins/logouts (to support remembering on multiple browsers simultaneously).
    # Default: false
    #
    # user.remember_me_token_persist_globally =

    # -- user_activation --
    # The attribute name to hold activation state (active/pending).
    # Default: `:activation_state`
    #
    # user.activation_state_attribute_name =

    # The attribute name to hold activation code (sent by email).
    # Default: `:activation_token`
    #
    # user.activation_token_attribute_name =

    # The attribute name to hold activation code expiration date.
    # Default: `:activation_token_expires_at`
    #
    # user.activation_token_expires_at_attribute_name =

    # How many seconds before the activation code expires. nil for never expires.
    # Default: `nil`
    #
    # user.activation_token_expiration_period =

    # REQUIRED:
    # User activation mailer class.
    # Default: `nil`
    #
    # user.user_activation_mailer =

    # When true, sorcery will not automatically
    # send the activation details email, and allow you to
    # manually handle how and when the email is sent.
    # Default: `false`
    #
    # user.activation_mailer_disabled =

    # Method to send email related
    # options: `:deliver_later`, `:deliver_now`, `:deliver`
    # Default: :deliver (Rails version < 4.2) or :deliver_now (Rails version 4.2+)
    #
    # user.email_delivery_method =

    # Activation needed email method on your mailer class.
    # Default: `:activation_needed_email`
    #
    # user.activation_needed_email_method_name =

    # Activation success email method on your mailer class.
    # Default: `:activation_success_email`
    #
    # user.activation_success_email_method_name =

    # Do you want to prevent users who did not activate by email from logging in?
    # Default: `true`
    #
    # user.prevent_non_active_users_to_login =

    # -- reset_password --
    # Password reset token attribute name.
    # Default: `:reset_password_token`
    #
    # user.reset_password_token_attribute_name =

    # Password token expiry attribute name.
    # Default: `:reset_password_token_expires_at`
    #
    # user.reset_password_token_expires_at_attribute_name =

    # When was password reset email sent. Used for hammering protection.
    # Default: `:reset_password_email_sent_at`
    #
    # user.reset_password_email_sent_at_attribute_name =

    # REQUIRED:
    # Password reset mailer class.
    # Default: `nil`
    #
    # user.reset_password_mailer =

    # Reset password email method on your mailer class.
    # Default: `:reset_password_email`
    #
    # user.reset_password_email_method_name =

    # When true, sorcery will not automatically
    # send the password reset details email, and allow you to
    # manually handle how and when the email is sent
    # Default: `false`
    #
    # user.reset_password_mailer_disabled =

    # How many seconds before the reset request expires. nil for never expires.
    # Default: `nil`
    #
    # user.reset_password_expiration_period =

    # Hammering protection: how long in seconds to wait before allowing another email to be sent.
    # Default: `5 * 60`
    #
    # user.reset_password_time_between_emails =

    # Access counter to a reset password page attribute name
    # Default: `:access_count_to_reset_password_page`
    #
    # user.reset_password_page_access_count_attribute_name =

    # -- magic_login --
    # Magic login code attribute name.
    # Default: `:magic_login_token`
    #
    # user.magic_login_token_attribute_name =

    # Magic login expiry attribute name.
    # Default: `:magic_login_token_expires_at`
    #
    # user.magic_login_token_expires_at_attribute_name =

    # When was magic login email sent — used for hammering protection.
    # Default: `:magic_login_email_sent_at`
    #
    # user.magic_login_email_sent_at_attribute_name =

    # REQUIRED:
    # Magic login mailer class.
    # Default: `nil`
    #
    # user.magic_login_mailer_class =

    # Magic login email method on your mailer class.
    # Default: `:magic_login_email`
    #
    # user.magic_login_email_method_name =

    # When true, sorcery will not automatically
    # send magic login details email, and allow you to
    # manually handle how and when the email is sent
    # Default: `true`
    #
    # user.magic_login_mailer_disabled =

    # How many seconds before the request expires. nil for never expires.
    # Default: `nil`
    #
    # user.magic_login_expiration_period =

    # Hammering protection: how long in seconds to wait before allowing another email to be sent.
    # Default: `5 * 60`
    #
    # user.magic_login_time_between_emails =

    # -- brute_force_protection --
    # Failed logins attribute name.
    # Default: `:failed_logins_count`
    #
    # user.failed_logins_count_attribute_name =

    # This field indicates whether user is banned and when it will be active again.
    # Default: `:lock_expires_at`
    #
    # user.lock_expires_at_attribute_name =

    # How many failed logins are allowed.
    # Default: `50`
    #
    # user.consecutive_login_retries_amount_limit =

    # How long the user should be banned, in seconds. 0 for permanent.
    # Default: `60 * 60`
    #
    # user.login_lock_time_period =

    # Unlock token attribute name
    # Default: `:unlock_token`
    #
    # user.unlock_token_attribute_name =

    # Unlock token mailer method
    # Default: `:send_unlock_token_email`
    #
    # user.unlock_token_email_method_name =

    # When true, sorcery will not automatically
    # send email with the unlock token
    # Default: `false`
    #
    # user.unlock_token_mailer_disabled = true

    # REQUIRED:
    # Unlock token mailer class.
    # Default: `nil`
    #
    # user.unlock_token_mailer =

    # -- activity logging --
    # Last login attribute name.
    # Default: `:last_login_at`
    #
    # user.last_login_at_attribute_name =

    # Last logout attribute name.
    # Default: `:last_logout_at`
    #
    # user.last_logout_at_attribute_name =

    # Last activity attribute name.
    # Default: `:last_activity_at`
    #
    # user.last_activity_at_attribute_name =

    # How long since user's last activity will they be considered logged out?
    # Default: `10 * 60`
    #
    # user.activity_timeout =

    # -- external --
    # Class which holds the various external provider data for this user.
    # Default: `nil`
    #
    # user.authentications_class =

    # User's identifier in the `authentications` class.
    # Default: `:user_id`
    #
    # user.authentications_user_id_attribute_name =

    # Provider's identifier in the `authentications` class.
    # Default: `:provider`
    #
    # user.provider_attribute_name =

    # User's external unique identifier in the `authentications` class.
    # Default: `:uid`
    #
    # user.provider_uid_attribute_name =
  end

  # This line must come after the 'user config' block.
  # Define which model authenticates with sorcery.
  config.user_class = "<%= model_class_name %>"
end

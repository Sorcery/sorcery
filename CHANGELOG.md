# Changelog
## HEAD

## 0.16.4

* Adapt to open request protection strategy of rails 7.0 [#318](https://github.com/Sorcery/sorcery/pull/318)
* Update OAuth2 gem to v2 per v1 deprecation [#323](https://github.com/Sorcery/sorcery/pull/323)
* Fixed typo in error message [#310](https://github.com/Sorcery/sorcery/pull/310)

## 0.16.3

* Fix provider instantiation for plural provider names (eg. okta) [#305](https://github.com/Sorcery/sorcery/pull/305)

## 0.16.2

* Inline core migration index definition [#281](https://github.com/Sorcery/sorcery/pull/281)
* Add missing remember_me attributes to config [#180](https://github.com/Sorcery/sorcery/pull/180)
* Fix MongoID adapter breaking on save [#284](https://github.com/Sorcery/sorcery/pull/284)
* Don't pass token to Slack in query params. Prevents 'invalid_auth' error [#287](https://github.com/Sorcery/sorcery/pull/287)
* Fix valid_password? not using configured values when called alone [#293](https://github.com/Sorcery/sorcery/pull/293)

## 0.16.1

* Fix default table name being incorrect in migration generator [#274](https://github.com/Sorcery/sorcery/pull/274)
* Update `oauth` dependency per CVE-2016-11086

## 0.16.0

* Add BattleNet Provider [#260](https://github.com/Sorcery/sorcery/pull/260)
* Fix failing isolated tests [#249](https://github.com/Sorcery/sorcery/pull/249)
* Support LINE login v2.1 [#251](https://github.com/Sorcery/sorcery/pull/251)
* Update generators to better support namespaces [#237](https://github.com/Sorcery/sorcery/pull/237)
* Add support for Rails 6 [#238](https://github.com/Sorcery/sorcery/pull/238)
* Fix ruby 2.7 deprecation warnings [#241](https://github.com/Sorcery/sorcery/pull/241)
* Use set to ensure unique arrays [#233](https://github.com/Sorcery/sorcery/pull/233)

## 0.15.1

* Update `oauth` dependency per CVE-2016-11086

## 0.15.0

* Fix brute force vuln due to callbacks no being ran [#235](https://github.com/Sorcery/sorcery/pull/235)
* Revert on_load change due to breaking existing applications [#234](https://github.com/Sorcery/sorcery/pull/234)
* Add forget_me! and force_forget_me! test cases [#216](https://github.com/Sorcery/sorcery/pull/216)
* In `generic_send_email`, check responds_to [#211](https://github.com/Sorcery/sorcery/pull/211)
* Fix typo [#219](https://github.com/Sorcery/sorcery/pull/219)
* Fix deprecation warnings in Rails 6 [#209](https://github.com/Sorcery/sorcery/pull/209)
* Add ruby 2.6.5 to the travis build [#215](https://github.com/Sorcery/sorcery/pull/215)
* Add discord provider [#185](https://github.com/Sorcery/sorcery/pull/185)
* Remove MySQL database creation call [#214](https://github.com/Sorcery/sorcery/pull/214)
* Use id instead of uid for VK provider [#199](https://github.com/Sorcery/sorcery/pull/199)
* Don't :return_t JSON requests after login [#197](https://github.com/Sorcery/sorcery/pull/197)
* Fix email scope for LinkedIn Provider [#191](https://github.com/Sorcery/sorcery/pull/191)
* Ignore cookies when undefined cookies [#187](https://github.com/Sorcery/sorcery/pull/187)
* Allow for custom providers with multi-word class names. [#190](https://github.com/Sorcery/sorcery/pull/190)

## 0.14.0

* Update LinkedIn to use OAuth 2 [#189](https://github.com/Sorcery/sorcery/pull/189)
* Support the LINE login auth [#80](https://github.com/Sorcery/sorcery/pull/80)
* Allow BCrypt to have app-specific secret token [#173](https://github.com/Sorcery/sorcery/pull/173)
* Add #change_password method to reset_password module. [#165](https://github.com/Sorcery/sorcery/pull/165)
* Clean up initializer comments [#153](https://github.com/Sorcery/sorcery/pull/153)
* Allow load_from_magic_login_token to accept a block [#152](https://github.com/Sorcery/sorcery/pull/152)
* Fix CipherError class name [#142](https://github.com/Sorcery/sorcery/pull/142)
* Fix `update_failed_logins_count` being called twice when login failed [#163](https://github.com/Sorcery/sorcery/pull/163)
* Update migration templates to use new hash syntax [#170](https://github.com/Sorcery/sorcery/pull/170)
* Support for Rails 4.2 and lower soft-dropped [#171](https://github.com/Sorcery/sorcery/pull/171)

## 0.13.0

* Add support for Rails 5.2 / Ruby 2.5 [#129](https://github.com/Sorcery/sorcery/pull/129)
* Fix migration files not being generated [#128](https://github.com/Sorcery/sorcery/pull/128)
* Add support for ActionController::API [#133](https://github.com/Sorcery/sorcery/pull/133), [#150](https://github.com/Sorcery/sorcery/pull/150), [#159](https://github.com/Sorcery/sorcery/pull/159)
* Update activation email to use after_commit callback [#130](https://github.com/Sorcery/sorcery/pull/130)
* Add opt-in `invalidate_active_sessions!` method [#110](https://github.com/Sorcery/sorcery/pull/110)
* Pass along `remember_me` to `#auto_login` [#136](https://github.com/Sorcery/sorcery/pull/136)
* Respect SessionTimeout on login via RememberMe [#102](https://github.com/Sorcery/sorcery/pull/102)
* Added `demodulize` on authentication class name association name fetch [#147](https://github.com/Sorcery/sorcery/pull/147)
* Remove Gemnasium badge [#140](https://github.com/Sorcery/sorcery/pull/140)
* Add Instragram provider [#51](https://github.com/Sorcery/sorcery/pull/51)
* Remove `publish_actions` permission for facebook [#139](https://github.com/Sorcery/sorcery/pull/139)
* Prepare for 1.0.0 [#157](https://github.com/Sorcery/sorcery/pull/157)
* Add Auth0 provider [#160](https://github.com/Sorcery/sorcery/pull/160)

## 0.12.0

* Fix magic_login not inheriting from migration_class_name [#99](https://github.com/Sorcery/sorcery/pull/99)
* Update YARD dependency [#100](https://github.com/Sorcery/sorcery/pull/100)
* Make `#update_attributes` behave like `#update` [#98](https://github.com/Sorcery/sorcery/pull/98)
* Add tests to the magic login submodule [#95](https://github.com/Sorcery/sorcery/pull/95)
* Set user.stretches to 1 in test env by default [#81](https://github.com/Sorcery/sorcery/pull/81)
* Allow user to be loaded from other source when session expires. fix #89 [#94](https://github.com/Sorcery/sorcery/pull/94)
* Added a new ArgumentError for not defined user_class in config [#82](https://github.com/Sorcery/sorcery/pull/82)
* Updated Required Ruby version to 2.2 [#85](https://github.com/Sorcery/sorcery/pull/85)
* Add configuration for token randomness [#67](https://github.com/Sorcery/sorcery/pull/67)
* Add facebook user_info_path option to initializer.rb [#63](https://github.com/Sorcery/sorcery/pull/63)
* Add new function: `build_from` (allows building a user instance from OAuth without saving) [#54](https://github.com/Sorcery/sorcery/pull/54)
* Add rubocop configuration and TODO list [#107](https://github.com/Sorcery/sorcery/pull/107)
* Add support for VK OAuth (thanks to @Hirurg103) [#109](https://github.com/Sorcery/sorcery/pull/109)
* Fix token leak via referrer header [#56](https://github.com/Sorcery/sorcery/pull/56)
* Add `login_user` helper for request specs [#57](https://github.com/Sorcery/sorcery/pull/57)

## 0.11.0

* Refer to User before calling remove_const to avoid NameError [#58](https://github.com/Sorcery/sorcery/pull/58)
* Resurrect block authentication, showing auth failure reason. [#41](https://github.com/Sorcery/sorcery/pull/41)
* Add github scope option to initializer.rb [#50](https://github.com/Sorcery/sorcery/pull/50)
* Fix Facebook being broken due to API deprecation [#53](https://github.com/Sorcery/sorcery/pull/53)

## 0.10.3

* Revert removal of MongoID Adapter (breaks Sorcery for MongoID users until separate gem is created) [#45](https://github.com/Sorcery/sorcery/pull/45)

## 0.10.2

* Added support for Microsoft OAuth (thanks to @athix) [#37](https://github.com/Sorcery/sorcery/pull/37)

## 0.10.1

* Fixed LinkedIn bug [#36](https://github.com/Sorcery/sorcery/pull/36)

## 0.10.0

* Adapters (Mongoid, MongoMapper, DataMapper) are now separated from the core Sorcery repo and moved under `sorcery-rails` organization. Special thanks to @juike!
* `current_users` method was removed
* Added `logged_in?` `logged_out?` `online?` to activity_logging instance methods
* Added support for PayPal OAuth (thanks to @rubenmoya)
* Added support for Slack OAuth (thanks to @youzik)
* Added support for WeChat OAuth (thanks to @Darmody)
* Deprecated Rails 3
  * Deprecated using `callback_filter` in favor of `callback_action`
  * Added null: false to migrations
* Added support for Rails 5 (thanks to @kyuden)
* Added support for Ruby 2.4 (thanks to @kyuden)
* Added WeChat provider to external submodule.
* Namespace login lock/unlock methods to fix conflicts with Rails lock/unlock (thanks to @kyuden)

## 0.9.1

* Fixed fetching private emails from github (thanks to @saratovsource)
* Added support for `active_for_authentication?` method (thanks to @gchaincl)
* Fixed migration bug for `external` submodule (thanks to @skv-headless)
* Added support for new Facebook Graph API (thanks to @mchaisse)
* Fixed issue with Xing submodule (thanks to @yoyostile)
* Fixed security bug with using `state` field in oAuth requests

## 0.9.0

* Sending emails works with Rails 4.2 (thanks to @wooly)
* Added `valid_password?` method
* Added support for JIRA OAuth (thanks to @camilasan)
* Added support for Heroku OAuth (thanks to @tyrauber)
* Added support for Salesforce OAuth (thanks to @supremebeing7)
* Added support for Mongoid 4
* Fixed issues with empty passwords (thanks to @Borzik)
* `find_by_provider_and_uid` method was replaced with `find_by_oauth_credentials`
* Sorcery::VERSION constant was added to allow easy version check
* `@user.setup_activation` method was made to be public (thanks @iTakeshi)
* `current_users` method is deprecated
* Fetching email from VK auth, thanks to @makaroni4
* Add logged_in? method to test_helpers (thanks to @oriolbcn)
* #locked? method is now public API (thanks @rogercampos)
* Introduces a new User instance method `generate_reset_password_token` to generate a new reset password token without sending an email (thanks to @tbuehl)

## 0.8.6

* `current_user` returns `nil` instead of `false` if there's no user loggd in (#493)
* MongoMapper adapter does not override `save!` method anymore. However due to ORM's lack of support for `validate: false` in `save!`, the combination of `validate: false` and `raise_on_failure: true` is not possible in MongoMapper. The errors will not be raised in this situation. (#151)
* Fixed rename warnings for bcrypt-ruby
* The way Sorcery adapters are included has been changed due to problem with multiple `included` blocks error in `ActiveSupport::Concern` class (#527)
* Session timeout works with new cookie serializer introduced in Rails 4.1
* Rails 4.1 compatibility bugs were fixed, this version is fully supported (#538)
* VK providers now supports `scope` option
* Support for DataMapper added
* Helpers for integration tests were added
* Fixed problems with special characters in user login attributes (MongoMapper & Mongoid)
* Fixed remaining `password_confirmation` value - it is now cleared just like `password`

## 0.8.5
* Fixed add_provider_to_user with CamelCased authentications_class model (#382)
* Fixed unlock_token_mailer_disabled to only disable automatic mailing (#467)
* Make send_email_* methods easier to overwrite (#473)
* Don't add `:username` field for User. Config option `username_attribute_names` is now `:email` by default instead of `:username`.

  If you're using `username` as main field for users to login, you'll need to tune your Sorcery config:

    ```ruby
    config.user_config do |user|
      # ...
      user.username_attribute_names = [:username]
    end
    ```
* `rails generate sorcery:install` now works inside Rails engine

## 0.8.4

* Few security fixes in `external` module

## 0.8.3 (yanked because of bad Jeweler release)

## 0.8.2

* Activity logging feature has a new column called `last_login_from_ip_address` (string type). If you use ActiveRecord, you will have to add this column to DB ([#465](https://github.com/NoamB/sorcery/issues/465))

## 0.7.5-0.8.1

<!-- HERE BE DRAGONS (Changelogs never written) -->

## 0.7.1-0.7.4

* Fixed a bug in the new generator
* Many bugfixes
* MongoMapper added to supported ORMs list, thanks @kbighorse
* Sinatra support discontinued!
* New generator contributed by @ahazem
* Cookie domain setting contributed by @Highcode


## 0.7.0

* Many bugfixes
* Added default SSL certificate for oauth2
* Added multi-username ability
* Security fixes (CSRF, cookie digesting)
* Added auto_login(user) to the API
* Updated gem versions of oauth(1/2)
* Added logged_in? as a view helper
* Github provider added to external submodule


## 0.6.1

Gemfile versions updated due to public demand.
(bcrypt 3.0.0 and oauth2 0.4.1)


## 0.6.0

Fixes issues with external user_hash not including some fields, and an issue with User model not loaded when user_class is called. Now config.user_class should be a string or a symbol.

Improved specs.

## 0.5.3

Fixed #9
Fixed hardcoded method names in remember_me submodule.
Improved specs.

## 0.5.21

Fixed typo in initializer - MUST be "config.user_class = User"

## 0.5.2

Fixed #3 and #4 - Modular Sinatra apps work now, and User model isn't cached in development mode.

## 0.5.1

Fixed bug in reset_password - after reset can't login due to bad salt creation. Affected only Mongoid.

## 0.5.0

Added support for Mongoid! (still buggy and not recommended for serious use)

'reset_password!(:password => new_password)' changed into 'change_password!(new_password)'

## 0.4.2

Added test helpers for Rails 3 & Sinatra.

## 0.4.1

Fixing Rails app name in initializer.

## 0.4.0

Changed the way Sorcery is configured.
Now inside the model only add:

```
authenticates_with_sorcery!
```

In the controller no code is needed! All configuration is done in an initializer.
Added a rake task to create it.

```
rake sorcery:bootstrap
```

## 0.3.1

Renamed "oauth" module to "external" and made API prettier.
```
auth_at_provider(provider) => login_at(provider)
login_from_access_token(provider) => login_from(provider)
create_from_provider!(provider) => create_from(provider)
```

## 0.3.0

Added Sinatra support!


Added Rails 3 generator for migrations


## 0.2.1

Fixed bug with OAuth submodule - oauth gems were not required properly in gem.


Fixed bug with OAuth submodule - Authentications class was not passed between model and controller in all cases resulting in Nil exception.


## 0.2.0

Added OAuth submodule.

### OAuth:
* OAuth1 and OAuth2 support (currently twitter & facebook)
* configurable db field names and authentications table.

Some bug fixes: 'return_to' feature, brute force permanent ban.


## 0.1.4

Added activity logging submodule.


### Activity Logging:
* automatic logging of last login, last logout and last activity time.
* an easy method of collecting the list of currently logged in users.
* configurable timeout by which to decide whether to include a user in the list of logged in users.


Fixed bug in basic_auth - it didn't set the session[:user_id] on successful login and tried to relogin from basic_auth on every action.


Added Reset Password hammering protection and updated the API.


Totally rewritten Brute Force Protection submodule.


## 0.1.3

Added support for Basic HTTP Auth.

## 0.1.2

Separated mailers between user_activation and password_reset and updated readme.

## 0.1.1

Fixed bug with BCrypt not being used properly by the lib and thus not working for authentication.

## 0.1.0

### Core Features:
* login/logout, optional redirect on login to where the user tried to reach before, configurable redirect for non-logged-in users.
* password encryption, algorithms: bcrypt(default), md5, sha1, sha256, sha512, aes256, custom(yours!), none. Configurable stretches and salt.
* configurable attribute names for username, password and email.
### User Activation:
* User activation by email with optional success email.
* configurable attribute names.
* configurable mailer.
* Optionally prevent active users to login.
### Password Reset:
* Reset password with email verification.
* configurable mailer, method name, and attribute name.
### Remember Me:
* Remember me with configurable expiration.
* configurable attribute names.
## Session Timeout:
* Configurable session timeout.
* Optionally session timeout will be calculated from last user action.
### Brute Force Protection:
* Brute force login hammering protection.
* configurable logins before ban, logins within time period before ban, ban time and ban action.

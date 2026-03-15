# Sorcery Test Coverage Baseline

> Generated as part of [Issue 1.1 — Audit Existing Test
> Coverage](https://github.com/Sorcery/sorcery/issues/new). This document
> records the baseline coverage numbers and identifies gaps to address before
> refactoring begins.

## Summary

| Metric          | Value              |
|-----------------|--------------------|
| **Line Coverage**   | **79.73%** (1,672 / 2,097 relevant lines) |
| **Branch Coverage** | **75.66%** (230 / 304 branches)            |
| **Test Count**      | 490 examples, 0 failures                  |

Coverage was collected with SimpleCov (`~> 0.22.0`) using `COVERAGE=true bundle
exec rake spec`. The configuration lives in `spec/spec_helper.rb` and tracks
all files under `lib/**/*.rb`, with branch coverage enabled.

To regenerate this report locally:

```sh
COVERAGE=true bundle exec rake spec
# HTML report → coverage/index.html
# Machine-readable → coverage/.resultset.json
```

---

## Per-File Coverage

### Files With 0 % Line Coverage (13 files, 180 lines)

These files are never exercised by the current test suite.

| File | Relevant Lines | Notes |
|------|---------------|-------|
| `lib/generators/sorcery/helpers.rb` | 35 | Generator helper methods |
| `lib/generators/sorcery/install_generator.rb` | 69 | Install generator logic |
| `lib/generators/sorcery/templates/initializer.rb` | 7 | Template file |
| `lib/generators/sorcery/templates/migration/activity_logging.rb` | 9 | Migration template |
| `lib/generators/sorcery/templates/migration/brute_force_protection.rb` | 8 | Migration template |
| `lib/generators/sorcery/templates/migration/core.rb` | 10 | Migration template |
| `lib/generators/sorcery/templates/migration/external.rb` | 10 | Migration template |
| `lib/generators/sorcery/templates/migration/magic_login.rb` | 8 | Migration template |
| `lib/generators/sorcery/templates/migration/remember_me.rb` | 7 | Migration template |
| `lib/generators/sorcery/templates/migration/reset_password.rb` | 9 | Migration template |
| `lib/generators/sorcery/templates/migration/user_activation.rb` | 8 | Migration template |
| `lib/sorcery/adapters/mongoid_adapter.rb` | 89 | Entire Mongoid adapter untested |
| `lib/sorcery/version.rb` | 3 | Version constant |

### Files With Low Coverage (< 80 % Line Coverage)

| File | Line Coverage | Branch Coverage | Key Gaps |
|------|-------------|----------------|----------|
| `lib/sorcery/providers/linkedin.rb` | 31.6 % (12/38) | 0.0 % (0/4) | `process_callback`, `get_user_hash`, `authorize_url` untested |
| `lib/sorcery/providers/heroku.rb` | 32.1 % (9/28) | 0.0 % (0/4) | `process_callback`, `get_user_hash` untested |
| `lib/sorcery/test_helpers/rails/request.rb` | 45.5 % (5/11) | 100 % | `login_user`/`logout_user` helpers untested |
| `lib/sorcery/test_helpers/rails/integration.rb` | 46.2 % (6/13) | 100 % | `login_user`/`logout_user` helpers untested |
| `lib/sorcery/providers/line.rb` | 59.3 % (16/27) | 0.0 % (0/4) | `process_callback`, `get_user_hash` untested |
| `lib/sorcery/model/submodules/external.rb` | 67.4 % (31/46) | 50.0 % (4/8) | `create_and_validate_from_provider`, `build_from_provider`, `link_from_provider` untested |
| `lib/sorcery/providers/jira.rb` | 73.1 % (19/26) | 0.0 % (0/2) | `process_callback`, `get_user_hash` untested |

### Files With Moderate Coverage (80–94 % Line Coverage)

| File | Line Coverage | Branch Coverage | Key Gaps |
|------|-------------|----------------|----------|
| `lib/sorcery/crypto_providers/bcrypt.rb` | 80.6 % (25/31) | 25.0 % (1/4) | `cost` default, `matches?` edge case (nil/empty hash), `reset` method |
| `lib/sorcery/test_helpers/internal.rb` | 84.2 % (32/38) | 100 % | Mongoid-related helpers untested |
| `lib/sorcery/providers/github.rb` | 86.2 % (25/29) | 50.0 % (3/6) | `get_user_hash` with organizations check |
| `lib/sorcery/protocols/oauth.rb` | 87.5 % (14/16) | 100 % | One-time callback URL creation flow |
| `lib/sorcery/controller/submodules/external.rb` | 89.5 % (94/105) | 72.2 % (13/18) | `create_from_provider`, `build_from_provider`, `access_token` accessor |
| `lib/sorcery.rb` | 90.6 % (58/64) | 50.0 % (3/6) | Mongoid adapter loading path, `user_class` error path |
| `lib/sorcery/providers/base.rb` | 90.5 % (19/21) | 80.0 % (8/10) | Edge cases in `auth_hash` and `original_callback_url` |
| `lib/sorcery/test_helpers/rails/controller.rb` | 91.7 % (11/12) | 100 % | One untested helper method |
| `lib/sorcery/adapters/active_record_adapter.rb` | 92.6 % (50/54) | 70.0 % (7/10) | `define_field` length parameter, `username_id_mapping` edge case |
| `lib/sorcery/protocols/oauth2.rb` | 93.3 % (14/15) | 100 % | One-time callback URL creation flow |
| `lib/sorcery/adapters/base_adapter.rb` | 93.8 % (15/16) | 100 % | One `NotImplementedError` method |
| `lib/sorcery/controller/submodules/http_basic_auth.rb` | 94.1 % (32/34) | 76.9 % (10/13) | Failed-auth realm response branch |
| `lib/sorcery/controller.rb` | 94.6 % (87/92) | 95.8 % (23/24) | `auto_login`, `after_login_lock` callback, invalid `user_class` error |
| `lib/sorcery/controller/submodules/remember_me.rb` | 94.9 % (37/39) | 87.5 % (7/8) | `force_forget_me!` path |
| `lib/sorcery/controller/config.rb` | 95.2 % (20/21) | 83.3 % (5/6) | Safe-navigation edge case |

### Files With Full or Near-Full Coverage (≥ 95 % Line Coverage)

| File | Line Coverage | Branch Coverage |
|------|-------------|----------------|
| `lib/sorcery/crypto_providers/aes256.rb` | 95.5 % (21/22) | 100 % |
| `lib/sorcery/test_helpers/internal/rails.rb` | 96.4 % (27/28) | 100 % |
| `lib/sorcery/providers/instagram.rb` | 96.7 % (29/30) | 50.0 % |
| `lib/sorcery/model/config.rb` | 97.7 % (43/44) | 90.9 % |
| `lib/sorcery/model.rb` | 98.0 % (100/102) | 85.0 % |
| `lib/sorcery/model/submodules/magic_login.rb` | 98.0 % (48/49) | 87.5 % |
| `lib/sorcery/model/submodules/reset_password.rb` | 98.6 % (69/70) | 91.7 % |
| `lib/sorcery/errors.rb` | 100 % | 100 % |
| `lib/sorcery/model/temporary_token.rb` | 100 % | 100 % |
| `lib/sorcery/model/submodules/user_activation.rb` | 100 % | 100 % |
| `lib/sorcery/model/submodules/remember_me.rb` | 100 % | 100 % |
| `lib/sorcery/model/submodules/activity_logging.rb` | 100 % | 100 % |
| `lib/sorcery/model/submodules/brute_force_protection.rb` | 100 % | 85.7 % |
| `lib/sorcery/controller/submodules/session_timeout.rb` | 100 % | 85.7 % |
| `lib/sorcery/controller/submodules/brute_force_protection.rb` | 100 % | 75.0 % |
| `lib/sorcery/controller/submodules/activity_logging.rb` | 100 % | 90.0 % |
| `lib/sorcery/crypto_providers/common.rb` | 100 % | 100 % |
| `lib/sorcery/crypto_providers/md5.rb` | 100 % | 100 % |
| `lib/sorcery/crypto_providers/sha1.rb` | 100 % | 100 % |
| `lib/sorcery/crypto_providers/sha256.rb` | 100 % | 100 % |
| `lib/sorcery/crypto_providers/sha512.rb` | 100 % | 100 % |
| `lib/sorcery/engine.rb` | 100 % | 50.0 % |
| All remaining providers (VK, Facebook, Twitter, Google, Salesforce, PayPal, Slack, WeChat, Microsoft, Auth0, Discord, BattleNet) | 100 % | 50–100 % |

---

## Coverage by Category

| Category | Lines Covered | Line Coverage | Priority |
|----------|-------------|-------------|----------|
| Generators | 0 / 180 | 0.0 % | Low — templates rarely change |
| Adapters | 65 / 159 | 40.9 % | Medium — Mongoid adapter entirely untested |
| Test Helpers | 81 / 102 | 79.4 % | Low — only used internally |
| Providers | 550 / 627 | 87.7 % | Medium — LinkedIn, Heroku, LINE, Jira have gaps |
| Other (sorcery.rb, version, errors) | 74 / 83 | 89.2 % | Low |
| Protocols (OAuth/OAuth2) | 28 / 31 | 90.3 % | Medium |
| Controller Submodules | 250 / 265 | 94.3 % | High — security-critical |
| Controller (Core) | 107 / 113 | 94.7 % | **High** — authentication core |
| Model Submodules | 349 / 366 | 95.4 % | High — password/token handling |
| Model (Core) | 168 / 171 | 98.2 % | **High** — password hashing core |
| Crypto Providers | 130 / 134 | 97.0 % | **High** — password hashing |

---

## Critical Code Paths Requiring Thorough Tests

The following code paths are security-sensitive and must have complete test
coverage before any refactoring begins.

### 1. Authentication (`Sorcery::Controller` core)

**Current coverage:** 94.6 % line, 95.8 % branch

| Method / Path | Status | Gap |
|---------------|--------|-----|
| `login` / `authenticate` | ✅ Covered | — |
| `logout` | ✅ Covered | — |
| `logged_in?` / `current_user` | ✅ Covered | — |
| `require_login` (before_action) | ✅ Covered | — |
| `auto_login(user)` | ⚠️ Not covered | Line 97 — sets `@current_user` without session |
| `login_user(user)` (internal) | ✅ Covered | — |
| `after_login_lock` callbacks | ⚠️ Not covered | Line 182 — callbacks after account lock |
| Invalid `user_class` error | ⚠️ Not covered | Line 188 — `ArgumentError` raise path |

### 2. Password Hashing (`Sorcery::CryptoProviders`)

**Current coverage:** BCrypt 80.6 %, all others 95–100 %

| Method / Path | Status | Gap |
|---------------|--------|-----|
| `BCrypt.encrypt` | ✅ Covered | — |
| `BCrypt.matches?` | ⚠️ Partial | nil/empty hash edge case (lines 77–81) not tested |
| `BCrypt.cost` (default) | ⚠️ Not covered | Line 55 — default cost value |
| `BCrypt.reset` | ⚠️ Not covered | Line 99 — resets cost to nil |
| `AES256.encrypt` / `matches?` | ✅ Covered | — |
| `SHA1/256/512.encrypt` / `matches?` | ✅ Covered | — |
| `MD5.encrypt` / `matches?` | ✅ Covered | — |
| `Common` shared module | ✅ Covered | — |

### 3. Session Management (`Sorcery::Controller` + submodules)

**Current coverage:** Session timeout 100 %, Remember Me 94.9 %

| Method / Path | Status | Gap |
|---------------|--------|-----|
| Session creation (`session[:user_id]`) | ✅ Covered | — |
| Session destruction (`reset_sorcery_session`) | ✅ Covered | — |
| `session_timeout` (expiry check) | ✅ Covered | — |
| `remember_me` (cookie set/auto-login) | ✅ Covered | — |
| `force_forget_me!` path | ⚠️ Not covered | Lines 43–44 — forced session invalidation |
| `remember_me_token` cookie domain | ✅ Covered | — |

### 4. Password Reset (`Sorcery::Model::Submodules::ResetPassword`)

**Current coverage:** 98.6 % line, 91.7 % branch

| Method / Path | Status | Gap |
|---------------|--------|-----|
| `deliver_reset_password_instructions!` | ✅ Covered | — |
| `change_password` / `change_password!` | ✅ Covered | — |
| Token generation and expiry | ✅ Covered | — |
| `clear_reset_password_token` | ⚠️ Partial | Line 159 — clearing expiry timestamp |

### 5. User Activation (`Sorcery::Model::Submodules::UserActivation`)

**Current coverage:** 100 % line, 100 % branch ✅

### 6. Brute Force Protection

**Current coverage:** Model 100 % (85.7 % branch), Controller 100 % (75 % branch)

| Method / Path | Status | Gap |
|---------------|--------|-----|
| `login_lock!` / `login_unlock!` | ✅ Covered | — |
| Lock duration / consecutive failures | ✅ Covered | — |
| Branch: unlock when threshold not reached | ⚠️ Not covered | Branch-only gap |

### 7. External / OAuth (`Sorcery::Model::Submodules::External` + Controller)

**Current coverage:** Model 67.4 %, Controller 89.5 %

| Method / Path | Status | Gap |
|---------------|--------|-----|
| `create_and_validate_from_provider` | ⚠️ Not covered | Lines 52–58 |
| `build_from_provider` | ⚠️ Not covered | Lines 83–90 |
| `link_from_provider` | ⚠️ Not covered | Lines 96–106 |
| Controller `create_from_provider` | ⚠️ Not covered | Lines 156–170 |
| Controller `build_from_provider` | ⚠️ Not covered | Lines 199–203 |
| Controller `access_token` accessor | ⚠️ Not covered | Line 101 |

### 8. Magic Login (`Sorcery::Model::Submodules::MagicLogin`)

**Current coverage:** 98.0 % line, 87.5 % branch

| Method / Path | Status | Gap |
|---------------|--------|-----|
| Token generation / delivery | ✅ Covered | — |
| Token expiry branch | ⚠️ Not covered | Branch-only gap at line 72 |

---

## Recommendations for Phase 1.2–1.5

Based on this audit, the following areas should be prioritized:

1. **External/OAuth model submodule** (67.4 %) — `create_and_validate_from_provider`,
   `build_from_provider`, and `link_from_provider` are entirely untested. These
   are called during OAuth sign-up and account-linking flows.

2. **BCrypt crypto provider** (80.6 %) — The `matches?` edge case with nil/empty
   hashes and the `cost`/`reset` methods need tests.

3. **Controller external submodule** (89.5 %) — `create_from_provider` and
   `build_from_provider` controller helpers need integration tests.

4. **OAuth providers** — LinkedIn (31.6 %), Heroku (32.1 %), LINE (59.3 %), and
   Jira (73.1 %) have significant gaps in their `process_callback` and
   `get_user_hash` methods.

5. **Controller core** (94.6 %) — `auto_login`, `after_login_lock` callbacks,
   and the invalid `user_class` error path should be tested.

6. **Generator tests** (0 %) — While low priority for refactoring safety, the
   install generator and migration templates are completely untested.

7. **Mongoid adapter** (0 %) — Entirely untested. Should be tested or marked for
   removal per V1_ROADMAP.md Phase 7.1.

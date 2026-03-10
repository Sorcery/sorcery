# Sorcery v1.0 Roadmap

This document outlines the plan for incrementally migrating Sorcery from its
current structure (v0.x) to the v1.0 architecture originally prototyped in
[Sorcery/sorcery-rework](https://github.com/Sorcery/sorcery-rework).

The consensus from [issue #417](https://github.com/Sorcery/sorcery/issues/417)
is to **modify this project in place** rather than replacing it with the rework
repository, making changes incrementally so the work can be completed in
manageable steps.

Each phase below is designed to be a discrete unit of work that can be tracked
as a GitHub issue. Phases should be completed in order, as later phases depend
on earlier ones.

---

## Phase 1: Improve Test Coverage

> **Goal:** Establish a robust test suite that can act as a safety net for
> structural refactoring.

This was identified as the most critical prerequisite by the maintainers. The
existing test suite has known coverage gaps that must be addressed before making
internal structural changes.

### 1.1 — Audit Existing Test Coverage

- [ ] Add `simplecov` to the test suite and generate a baseline coverage report.
- [ ] Document which modules, classes, and methods have insufficient or no
      coverage.
- [ ] Identify critical code paths (authentication, password hashing, session
      management) that must have thorough tests before any refactoring begins.

### 1.2 — Improve Model Submodule Test Coverage

- [ ] Review and expand tests for `Sorcery::Model` core (user creation,
      password hashing, authentication).
- [ ] Improve coverage for each model submodule:
  - [ ] `user_activation`
  - [ ] `reset_password`
  - [ ] `remember_me`
  - [ ] `activity_logging`
  - [ ] `brute_force_protection`
  - [ ] `external` (OAuth)
  - [ ] `magic_login`
- [ ] Ensure edge cases are covered (e.g., expired tokens, invalid inputs,
      concurrent sessions).

### 1.3 — Improve Controller Submodule Test Coverage

- [ ] Review and expand tests for `Sorcery::Controller` core (login, logout,
      session management).
- [ ] Improve coverage for each controller submodule:
  - [ ] `remember_me`
  - [ ] `session_timeout`
  - [ ] `brute_force_protection`
  - [ ] `http_basic_auth`
  - [ ] `activity_logging`
  - [ ] `external` (OAuth)
- [ ] Add integration tests that exercise multiple submodules working together.

### 1.4 — Improve Provider Test Coverage

- [ ] Audit and expand tests for OAuth/OAuth2 protocol handling.
- [ ] Add or improve tests for individual providers (only those with testable
      logic, not just configuration).
- [ ] Add tests for provider error handling and edge cases.

### 1.5 — Improve CryptoProvider Test Coverage

- [ ] Ensure all crypto providers (BCrypt, AES256, MD5, SHA1, SHA256, SHA512)
      have thorough tests.
- [ ] Add tests for the `Common` module shared behavior.
- [ ] Test password migration scenarios between different providers.

---

## Phase 2: Introduce the Plugin Architecture

> **Goal:** Unify the split model/controller submodule pattern into a single
> plugin pattern, matching the rework's `Sorcery::Plugin` module.

In the current codebase, each feature (e.g., activity logging) is split across
`Sorcery::Model::Submodules::ActivityLogging` and
`Sorcery::Controller::Submodules::ActivityLogging`. The rework unifies these
into `Sorcery::Plugins::ActivityLogging` with `Model` and `Controller`
sub-modules.

### 2.1 — Create the Plugin Base Module

- [ ] Implement `Sorcery::Plugin` module (based on the rework's
      `sorcery-core/lib/sorcery/plugin.rb`).
- [ ] Define the plugin interface: `add_methods`, `add_config`, `add_callbacks`,
      `plugin_defaults`, `plugin_dependencies`.
- [ ] Add tests for the plugin loading mechanism.

### 2.2 — Create the Plugins Namespace

- [ ] Create `Sorcery::Plugins` module with `plugin_const` and
      `plugin_const_name` helpers.
- [ ] Add the autoload entries for all plugins.

### 2.3 — Migrate Submodules to Plugins (One at a Time)

Migrate each feature from the split model/controller submodule structure to the
unified plugin structure. Each plugin should be a separate PR:

- [ ] `activity_logging` → `Sorcery::Plugins::ActivityLogging`
- [ ] `brute_force_protection` → `Sorcery::Plugins::BruteForceProtection`
- [ ] `http_basic_auth` → `Sorcery::Plugins::HttpBasicAuth`
- [ ] `remember_me` → `Sorcery::Plugins::RememberMe`
- [ ] `reset_password` → `Sorcery::Plugins::ResetPassword`
- [ ] `session_timeout` → `Sorcery::Plugins::SessionTimeout`
- [ ] `user_activation` → `Sorcery::Plugins::UserActivation`
- [ ] `magic_login` → `Sorcery::Plugins::MagicLogin`

Each migration should:
1. Create the new plugin under `lib/sorcery/plugins/<name>/`.
2. Include both `Model` and `Controller` sub-modules within the plugin.
3. Keep the old submodule files as thin wrappers that delegate to the new plugin
   (for backwards compatibility during the transition).
4. Ensure all existing tests pass without modification.

### 2.4 — Deprecate Old Submodule Loading

- [ ] Add deprecation warnings when submodules are loaded via the old path
      (e.g., `config.submodules = [:activity_logging]`).
- [ ] Document the new `config.load_plugin(:activity_logging)` API.
- [ ] Plan removal of old paths for v1.1 or v2.0.

---

## Phase 3: Refactor Configuration System

> **Goal:** Modernize the config to use the singleton pattern from the rework,
> supporting per-controller configuration.

### 3.1 — Refactor `Sorcery::Config` to Singleton Pattern

- [ ] Implement the singleton `Config.instance` pattern (based on the rework's
      `sorcery-core/lib/sorcery/config.rb`).
- [ ] Support `Sorcery.configure { |config| ... }` as a convenience method.
- [ ] Ensure `add_defaults`, `add_plugin_defaults`, `add_callbacks` work with
      the new pattern.
- [ ] Add `Config#reset!`, `Config#merge`, `Config#dup` methods.
- [ ] Maintain backwards compatibility with `Sorcery::Controller::Config` during
      transition.

### 3.2 — Support Per-Controller Configuration

- [ ] Allow `authenticates_with_sorcery!` on individual controllers to override
      global config.
- [ ] Support `config.load_plugin` / `config.unload_plugin` per-controller.
- [ ] Add tests for per-controller config isolation.

### 3.3 — Deprecate `Sorcery::Controller::Config`

- [ ] Add deprecation notices for direct access to
      `Sorcery::Controller::Config`.
- [ ] Redirect to the new `Sorcery::Config` location.

---

## Phase 4: Switch from Engine to Railtie

> **Goal:** Replace the Rails Engine with a Railtie for lighter-weight Rails
> integration.

### 4.1 — Implement `Sorcery::Railtie`

- [ ] Create `Sorcery::Railtie < Rails::Railtie` (based on the rework's
      `sorcery-core/lib/sorcery/railtie.rb`).
- [ ] Use `ActiveSupport.on_load` hooks for `action_controller_api`,
      `action_controller_base`, and `active_record` instead of eagerly
      extending classes.
- [ ] Expose `config.sorcery` through the Railtie.

### 4.2 — Migrate from Engine to Railtie

- [ ] Replace `Sorcery::Engine` with `Sorcery::Railtie`.
- [ ] Remove eager loading of `ActionController` and `ActiveRecord` extensions
      from `lib/sorcery.rb`.
- [ ] Ensure generators still work correctly.
- [ ] Run full test suite to validate no regressions.

### 4.3 — Switch to Autoloading

- [ ] Replace explicit `require` calls with `autoload` where appropriate
      (following the rework's pattern).
- [ ] Ensure all modules load correctly in development, test, and production
      environments.

---

## Phase 5: Extract OAuth into Separate Gem

> **Goal:** Move OAuth/OAuth2 provider support into `sorcery-oauth` gem within
> a monorepo structure.

### 5.1 — Prepare Monorepo Structure

- [ ] Create the `sorcery-core/` directory with its own gemspec.
- [ ] Move core library files into `sorcery-core/lib/`.
- [ ] Create shared `SORCERY_VERSION` file for version synchronization across
      gems.
- [ ] Update the root `sorcery.gemspec` to become a meta-gem that depends on
      `sorcery-core`.
- [ ] Ensure `gem 'sorcery'` still works seamlessly for existing users.

### 5.2 — Extract OAuth to `sorcery-oauth`

- [ ] Create the `sorcery-oauth/` directory with its own gemspec.
- [ ] Move OAuth-related code:
  - `lib/sorcery/providers/` → `sorcery-oauth/lib/sorcery/providers/`
  - `lib/sorcery/protocols/` → `sorcery-oauth/lib/sorcery/protocols/`
  - Model submodule `external` → `sorcery-oauth/lib/sorcery/plugins/external/`
  - Controller submodule `external` → same plugin
- [ ] Make `sorcery-oauth` depend on `sorcery-core`.
- [ ] Remove `oauth` and `oauth2` as hard dependencies of the core gem.
- [ ] Update the meta-gem to optionally depend on `sorcery-oauth`.
- [ ] Add deprecation notices guiding users to add `sorcery-oauth` to their
      Gemfile if they use OAuth features.
- [ ] Ensure all OAuth tests pass with the new gem structure.

### 5.3 — Update Generators for OAuth

- [ ] Update the install generator to detect when `sorcery-oauth` is present.
- [ ] Update migration generators for the OAuth-related tables.

---

## Phase 6: Add New Capabilities (JWT, MFA)

> **Goal:** Introduce JWT and MFA support as separate gems, as prototyped in
> the rework.

### 6.1 — Add `sorcery-jwt` Gem

- [ ] Create `sorcery-jwt/` directory with its own gemspec.
- [ ] Implement JWT-based session management as a plugin.
- [ ] Add `jwt` as a dependency of `sorcery-jwt`.
- [ ] Add comprehensive tests for JWT authentication flow.
- [ ] Document configuration and usage.

### 6.2 — Add `sorcery-mfa` Gem

- [ ] Create `sorcery-mfa/` directory with its own gemspec.
- [ ] Implement MFA as a plugin (TOTP, recovery codes).
- [ ] Add comprehensive tests for MFA authentication flow.
- [ ] Document configuration and usage.

### 6.3 — Consider Passkeys Support

- [ ] Evaluate adding `sorcery-passkeys` gem (per
      [sorcery-rework#14](https://github.com/Sorcery/sorcery-rework/issues/14)).
- [ ] Coordinate with the
      [ruby-passkeys](https://github.com/ruby-passkeys) organization.

---

## Phase 7: Cleanup and Release

> **Goal:** Remove deprecated code paths, finalize the public API, and release
> v1.0.0.

### 7.1 — Remove Deprecated Code

- [ ] Remove old `Sorcery::Model::Submodules` namespace.
- [ ] Remove old `Sorcery::Controller::Submodules` namespace.
- [ ] Remove old `Sorcery::Controller::Config` redirect.
- [ ] Remove `Sorcery::Engine` (fully replaced by Railtie).
- [ ] Remove Mongoid adapter if not maintained (or extract to separate gem).
- [ ] Clean up any remaining `require` calls replaced by `autoload`.

### 7.2 — Finalize Public API

- [ ] Audit all public methods and ensure they are intentional.
- [ ] Add `@api private` YARD tags to internal methods.
- [ ] Rename `encrypt` methods to `digest` (with deprecation in 0.x releases
      per [sorcery-rework#7](https://github.com/Sorcery/sorcery-rework/issues/7)).
- [ ] Ensure `Sorcery::CryptoProviders.secure_compare` is available and tested.

### 7.3 — Update Documentation

- [ ] Update README.md with v1.0 configuration examples.
- [ ] Update MAINTAINING.md with monorepo release procedures.
- [ ] Update CHANGELOG.md or GitHub Releases with migration guide.
- [ ] Update wiki with new plugin architecture documentation.

### 7.4 — Release v1.0.0

- [ ] Run full test suite across all supported Rails versions.
- [ ] Create a migration guide for v0.x → v1.0 users.
- [ ] Tag and release `sorcery-core`, `sorcery-oauth`, and `sorcery` meta-gem.
- [ ] Publish to RubyGems.

---

## Architectural Reference

### Current Structure (v0.x)

```
sorcery/
├── lib/
│   ├── sorcery.rb
│   ├── sorcery/
│   │   ├── engine.rb              # Rails Engine
│   │   ├── model.rb               # Model mixin
│   │   ├── model/
│   │   │   ├── config.rb
│   │   │   └── submodules/        # Model-side features
│   │   │       ├── activity_logging.rb
│   │   │       ├── brute_force_protection.rb
│   │   │       ├── external.rb
│   │   │       ├── magic_login.rb
│   │   │       ├── remember_me.rb
│   │   │       ├── reset_password.rb
│   │   │       └── user_activation.rb
│   │   ├── controller.rb          # Controller mixin
│   │   ├── controller/
│   │   │   ├── config.rb
│   │   │   └── submodules/        # Controller-side features
│   │   │       ├── activity_logging.rb
│   │   │       ├── brute_force_protection.rb
│   │   │       ├── external.rb
│   │   │       ├── http_basic_auth.rb
│   │   │       ├── remember_me.rb
│   │   │       └── session_timeout.rb
│   │   ├── providers/             # OAuth providers (bundled)
│   │   └── crypto_providers/      # Password hashing
│   └── generators/
└── sorcery.gemspec                # Single gem
```

### Target Structure (v1.0)

```
sorcery/
├── sorcery-core/
│   ├── lib/
│   │   ├── sorcery-core.rb
│   │   └── sorcery/
│   │       ├── railtie.rb         # Railtie (replaces Engine)
│   │       ├── config.rb          # Unified config (singleton)
│   │       ├── plugin.rb          # Plugin base module
│   │       ├── model.rb           # Model mixin
│   │       ├── controller.rb      # Controller mixin
│   │       ├── plugins/           # Unified plugins
│   │       │   ├── activity_logging/
│   │       │   │   ├── model.rb
│   │       │   │   └── controller.rb
│   │       │   ├── brute_force_protection/
│   │       │   ├── http_basic_auth/
│   │       │   ├── magic_login/
│   │       │   ├── remember_me/
│   │       │   ├── reset_password/
│   │       │   ├── session_timeout/
│   │       │   └── user_activation/
│   │       ├── crypto_providers/
│   │       └── orm_adapters/
│   └── sorcery-core.gemspec
├── sorcery-oauth/
│   ├── lib/
│   │   ├── sorcery-oauth.rb
│   │   └── sorcery/
│   │       ├── plugins/external/
│   │       └── providers/
│   └── sorcery-oauth.gemspec
├── sorcery-jwt/
│   ├── lib/
│   └── sorcery-jwt.gemspec
├── sorcery-mfa/
│   ├── lib/
│   └── sorcery-mfa.gemspec
├── spec/                          # Shared test suite
├── SORCERY_VERSION                # Shared version file
└── sorcery.gemspec                # Meta-gem
```

---

## Key Principles

1. **Incremental Progress** — Each phase should result in a working, releasable
   state. No big-bang rewrites.
2. **Backwards Compatibility** — Deprecate before removing. Users on v0.x should
   have a clear upgrade path.
3. **Test-First** — No structural changes without sufficient test coverage to
   catch regressions.
4. **One PR Per Step** — Keep pull requests focused on a single step from this
   roadmap for easier review.

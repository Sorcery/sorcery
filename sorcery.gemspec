lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sorcery/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.name = 'sorcery'
  s.version = Sorcery::VERSION
  s.authors = [
    'Noam Ben Ari',
    'Kir Shatrov',
    'Grzegorz Witek',
    'Chase Gilliam',
    'Josh Buker'
  ]
  s.email = [
    'crypto@joshbuker.com'
  ]

  # TODO: Cleanup formatting.
  # rubocop:disable Layout/LineLength
  s.description = 'Provides common authentication needs such as signing in/out, activating by email and resetting password.'
  s.summary = 'Magical authentication for Rails applications'
  s.homepage = 'https://github.com/Sorcery/sorcery'
  s.metadata = {"bug_tracker_uri" => "https://github.com/Sorcery/sorcery/issues", "changelog_uri" => "https://github.com/Sorcery/sorcery/blob/master/CHANGELOG.md"}
  s.post_install_message = "As of version 1.0 oauth/oauth2 won't be automatically bundled so you may need to add those dependencies to your Gemfile.\n"
  s.post_install_message += 'You may need oauth2 if you use external providers such as any of these: https://github.com/Sorcery/sorcery/tree/master/lib/sorcery/providers'
  # rubocop:enable Layout/LineLength

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.required_ruby_version = '>= 3.2.0'

  s.add_dependency 'bcrypt', '~> 3.1'
  s.add_dependency 'oauth', '>= 0.6'
  s.add_dependency 'oauth2', '~> 2.0'

  s.add_development_dependency 'byebug', '~> 11.1.3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'test-unit', '~> 3.2.0'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'webmock', '~> 3.3.0'
  s.add_development_dependency 'yard', '~> 0.9.0', '>= 0.9.12'
end
# rubocop:enable Metrics/BlockLength

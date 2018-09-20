lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sorcery/version'

Gem::Specification.new do |s|
  s.name = 'sorcery'
  s.version = Sorcery::VERSION
  s.authors = ['Noam Ben Ari', 'Kir Shatrov', 'Grzegorz Witek', 'Chase Gilliam']
  s.email = 'chase.gilliam@gmail.com'
  s.description = 'Provides common authentication needs such as signing in/out, activating by email and resetting password.'
  s.summary = 'Magical authentication for Rails applications'
  s.homepage = 'https://github.com/Sorcery/sorcery'
  s.post_install_message = "As of version 1.0 oauth/oauth2 won't be automatically bundled so you may need to add those dependencies to your Gemfile.\n"
  s.post_install_message += 'You may need oauth2 if you use external providers such as any of these: https://github.com/Sorcery/sorcery/tree/master/lib/sorcery/providers'

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'oauth', '~> 0.4', '>= 0.4.4'
  s.add_dependency 'oauth2', '~> 1.0', '>= 0.8.0'
  s.add_dependency 'bcrypt', '~> 3.1'

  s.add_development_dependency 'yard', '~> 0.9.0', '>= 0.9.12'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'simplecov', '>= 0.3.8'
  s.add_development_dependency 'rspec-rails', '~> 3.7.0'
  s.add_development_dependency 'test-unit', '~> 3.2.0'
  s.add_development_dependency 'byebug', '~> 10.0.0'
  s.add_development_dependency 'webmock', '~> 3.3.0'
end

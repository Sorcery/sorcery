require 'spec_helper'
require 'open3'

describe 'require sorcery without rails' do
  it 'should not raise any error' do
    Open3.popen3("ruby") do |stdin, stdout, stderr, wait_thr|
      stdin.puts(<<-RUBY)
        require 'bundler/inline'
        gemfile do
          source 'https://rubygems.org'
          gem 'sorcery', path: '.'
        end
      RUBY
      stdin.close

      wait_thr.join

      expect(stdout.read).to eq ""
      expect(stderr.read).to eq ""
    end
  end
end

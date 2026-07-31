source 'https://rubygems.org'

# Specify your gem's dependencies in net-sftp.gemspec
gemspec

gem 'debug', group: %i[development test], require: false if !Gem.win_platform? && RUBY_ENGINE == "ruby"

group :development, :test do
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'bundler-audit', require: false
end

source 'https://rubygems.org'
ruby '2.5.1'

# Web API
gem 'roda'
gem 'puma'
gem 'json'

# Configuration
gem 'econfig'
gem 'rake'

# Diagnostic
gem 'pry'
gem 'rack-test'

# Security
gem 'rbnacl-libsodium'

# Services
gem 'http'

# Database
gem 'sequel'
gem 'sequel-seed'
gem 'hirb'

group :development, :test do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end


# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Development
group :development do
  gem 'rubocop'
end

group :development, :test do
  gem 'rerun'
end
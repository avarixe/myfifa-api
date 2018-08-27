# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bootsnap'

gem 'rack-attack'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use PostgreSQL as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'figaro'

# Devise authentication
gem 'devise'
gem 'doorkeeper'

gem 'cancancan'

gem 'activerecord-import'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'date_validator'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS),
# making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  gem 'byebug', platform: :mri

  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'

  gem 'annotate', require: false
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'rails-erd'
  gem 'rubocop', require: false
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

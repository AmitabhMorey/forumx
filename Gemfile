source "https://rubygems.org"

gem "importmap-rails"
gem "jbuilder"
gem "pg", "~> 1.5"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"

# Authentication & Authorization
gem "devise"
gem "pundit"

# Background processing & Caching
gem "redis", "~> 5.0"
gem "sidekiq"

# Markdown rendering & Sanitization
gem "kramdown"
gem "sanitize"

# Pagination
gem "kaminari"

# Active Storage image processing
gem "image_processing", "~> 1.2"

# Reduces boot times through caching
gem "bootsnap", require: false

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails", "~> 8.0"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

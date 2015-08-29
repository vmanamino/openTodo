source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# postgre in production, rails_12factor for serving assets
group :production do
  gem 'pg'
  gem 'rails_12factor'
end
# in dev use sqlite3 for active record
group :development do
  gem 'sqlite3'
end

# test frameworks
group :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara', '~> 2.3.0'
  gem 'shoulda-matchers', '~> 3.0.0.alpha'
end
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # find style convention errors
  gem 'rubocop', require: false
end

# read sensitive data from env variables
gem 'figaro', '1.0'

# serialize my models
gem 'active_model_serializers', '0.9.2'

# for rspec tests, easily generate my models
gem 'factory_girl_rails', '~> 4.0'



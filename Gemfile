source "http://www.rubygems.org"

# runtime dependencies
gemspec

# dependencies not needed during CI
group :optional do
  gem 'byebug',                     '>= 0',     platforms: [:ruby_20, :ruby_21, :ruby_22, :ruby_23]
  gem 'pry',                        '>= 0',     platforms: :ruby
  gem 'gem-release',                '~> 0.7.4'
  gem 'benchmark-ips',              '>= 0'
end

group :development, :test do
  gem 'rspec',                      '~> 3.5'
  gem 'codeclimate-test-reporter',  '~> 0.6.0'
  gem 'simplecov',                  '~> 0.12.0'
  gem 'rake',                       '~> 11.3'
end

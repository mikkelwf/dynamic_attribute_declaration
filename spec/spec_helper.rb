require 'active_record'
require 'database_cleaner'
require 'rspec/its'

# Initialize AR connection
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
# Require dynamic_attribute_declaration gem
require 'dynamic_attribute_declaration'
# Load and build test models
require 'support/models'

# Configure RSpec
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
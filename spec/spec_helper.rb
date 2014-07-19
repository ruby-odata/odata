if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'odata'

require 'timecop'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :typhoeus
  c.default_cassette_options = { record: :new_episodes, erb: true }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 3
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.after(:example) do
    # We're calling this as a private method because there should not be any
    # reasons to have to flush the service registry except in testing.
    OData::ServiceRegistry.instance.send(:flush)
  end
end

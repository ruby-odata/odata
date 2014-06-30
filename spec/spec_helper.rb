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

require 'webmock/rspec'
if ENV['REAL_HTTP']
  WebMock.allow_net_connect!
else
  WebMock.disable_net_connect!(allow_localhost: true, allow: 'codeclimate.com')
end

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 3
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.before(:example) do
    unless ENV['REAL_HTTP']
      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/$metadata').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/metadata.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/products.xml'))

      stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products/$count').
          to_return(status: 200, :body => '11')

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products(0)').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/product_0.xml'))
    end
  end
end

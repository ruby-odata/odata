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
if ENV['REAL_HTTP'] == 'true'
  WebMock.allow_net_connect!
else
  WebMock.disable_net_connect!(allow_localhost: true, allow: 'codeclimate.com')
end

require 'timecop'

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
    unless ENV['REAL_HTTP'] == 'true'
      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/$metadata').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/metadata.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/products.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products?$inlinecount=allpages&$skip=0&$top=5').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/products_skip0_top5.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products?$inlinecount=allpages&$skip=5&$top=5').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/products_skip5_top5.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products?$inlinecount=allpages&$skip=10&$top=5').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/products_skip10_top5.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products?$skip=0&$top=1').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/first_product.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products/$count').
          to_return(status: 200, :body => '11')

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products(0)').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/product_0.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products(99)').
          to_return(status: 404, body: File.open('spec/fixtures/sample_service/product_not_found.xml'))

      WebMock.stub_request(:get, "http://services.odata.org/OData/OData.svc/Products?$filter=Name%20eq%20'Bread'").
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/product_filter_one.xml'))

      WebMock.stub_request(:get, 'http://services.odata.org/OData/OData.svc/Products?$filter=Rating%20eq%203').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/product_filter_many.xml'))
    end
  end

  config.after(:example) do
    # We're calling this as a private method because there should not be any
    # reasons to have to flush the service registry except in testing.
    OData::ServiceRegistry.instance.send(:flush)
    WebMock.reset!
  end
end

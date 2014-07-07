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
    end

    # CAUTION
    #
    # We Don't have access to a publicly writable OData Service to talk to, so
    # these calls always need to be mocked.
    #
    WebMock.stub_request(:post, 'http://services.odata.org/OData/OData.svc/Products').
        #with(body: "<?xml version=\"1.0\"?>\n<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:data=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:metadata=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns:georss=\"http://www.georss.org/georss\" xmlns:gml=\"http://www.opengis.net/gml\" xml:base=\"http://services.odata.org/OData/OData.svc/\"><category term=\"ODataDemo.Product\" scheme=\"http://schemas.microsoft.com/ado/2007/08/dataservices/scheme\"/><author><name/></author><content type=\"application/xml\"><metadata:properties><data:Name metadata:type=\"Edm.String\">Widget</data:Name><data:Description metadata:type=\"Edm.String\">Just a simple widget</data:Description><data:ReleaseDate metadata:type=\"Edm.DateTime\">2014-07-07T20:12:25.607</data:ReleaseDate><data:DiscontinuedDate metadata:type=\"Edm.DateTime\" metadata:null=\"true\"/><data:Rating metadata:type=\"Edm.Int16\">4</data:Rating><data:Price metadata:type=\"Edm.Double\">3.5</data:Price></metadata:properties></content>\n</entry>\n").
        to_return(status: 201, body: File.open('spec/fixtures/sample_service/product_9999.xml'))

    WebMock.stub_request(:post, 'http://services.odata.org/OData/OData.svc/Products').
        with(:body => "<?xml version=\"1.0\"?>\n<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:data=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:metadata=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns:georss=\"http://www.georss.org/georss\" xmlns:gml=\"http://www.opengis.net/gml\" xml:base=\"http://services.odata.org/OData/OData.svc/\"><category term=\"ODataDemo.Product\" scheme=\"http://schemas.microsoft.com/ado/2007/08/dataservices/scheme\"/><author><name/></author><content type=\"application/xml\"><metadata:properties><data:Name metadata:type=\"Edm.String\" metadata:null=\"true\"/><data:Description metadata:type=\"Edm.String\" metadata:null=\"true\"/><data:ReleaseDate metadata:type=\"Edm.DateTime\" metadata:null=\"true\"/><data:DiscontinuedDate metadata:type=\"Edm.DateTime\" metadata:null=\"true\"/><data:Rating metadata:type=\"Edm.Int16\" metadata:null=\"true\"/><data:Price metadata:type=\"Edm.Double\" metadata:null=\"true\"/></metadata:properties></content>\n</entry>\n").
        to_return(status: 400, body: nil)

    WebMock.stub_request(:post, 'http://services.odata.org/OData/OData.svc/Products(0)').
        to_return(status: 200, body: File.open('spec/fixtures/sample_service/product_0.xml'))
  end

  config.after(:example) do
    # We're calling this as a private method because there should not be any
    # reasons to have to flush the service registry except in testing.
    OData::ServiceRegistry.instance.send(:flush)
  end
end

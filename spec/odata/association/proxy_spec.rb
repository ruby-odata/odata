require 'spec_helper'

describe OData::Association::Proxy, vcr: {cassette_name: 'association_proxy_specs'} do
  before :each do
    OData::Service.open('http://services.odata.org/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::Association::Proxy.new('ODataDemo.Product', service) }
  let(:service) { OData::ServiceRegistry['ODataDemo'] }

  it { expect(subject).to respond_to(:service) }
  it { expect(subject).to respond_to(:namespace) }
  it { expect(subject).to respond_to(:entity_type) }

  it { expect(subject).to respond_to(:[]) }
  it { expect(subject).to respond_to(:size)}
end
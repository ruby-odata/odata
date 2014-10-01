require 'spec_helper'

describe OData::Association::Proxy, vcr: {cassette_name: 'association_proxy_specs'} do
  before :each do
    OData::Service.open('http://services.odata.org/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::Association::Proxy.new(entity) }
  let(:entity) { OData::ServiceRegistry['ODataDemo']['Products'].first }

  it { expect(subject).to respond_to(:size)}

  describe '#[]' do
    it { expect(subject).to respond_to(:[]) }
    it { expect(subject['ProductDetail']).to be_a(OData::Entity) }
    it { expect(subject['Categories']).to be_a(Enumerable) }
    it { expect(subject['Categories'].first).to be_a(OData::Entity) }
  end
end
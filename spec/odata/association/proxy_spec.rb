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

    context 'when no links exist for an entity' do
      before(:each) do
        expect(entity).to receive(:links) do
          { 'ProductDetail' => nil, 'Categories' => nil }
        end
      end

      context 'for a many association' do
        it { expect(subject['Categories']).to eq([]) }
      end

      context 'for a singular association' do
        it { expect(subject['ProductDetail']).to eq(nil) }
      end
    end
  end
end
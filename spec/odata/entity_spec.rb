require 'spec_helper'

describe OData::Entity, vcr: {cassette_name: 'entity_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::Entity.new(options) }
  let(:options) { {
      type:         'ODataDemo.Product',
      namespace:    'ODataDemo',
      service_name: 'ODataDemo'
  } }

  it { expect(subject).to respond_to(:name, :type, :namespace, :service_name) }

  it { expect(subject.name).to eq('Product') }
  it { expect(subject.type).to eq('ODataDemo.Product') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.service_name).to eq('ODataDemo') }

  describe '#associations' do
    it { expect(subject).to respond_to(:associations) }
    it { expect(subject.associations.size).to eq(3) }
    it { expect(subject.associations['Categories']).to be_a(OData::Association) }
    it { expect {subject.associations['NonExistant']}.to raise_error(ArgumentError) }
  end

  describe '.from_xml' do
    let(:subject) { OData::Entity.from_xml(product_xml, options) }
    let(:product_xml) {
      document = ::Nokogiri::XML(File.open('spec/fixtures/sample_service/product_0.xml'))
      document.remove_namespaces!
      document.xpath('//entry').first
    }

    it { expect(OData::Entity).to respond_to(:from_xml) }
    it { expect(subject).to be_a(OData::Entity) }

    it { expect(subject.name).to eq('Product') }
    it { expect(subject.type).to eq('ODataDemo.Product') }
    it { expect(subject.namespace).to eq('ODataDemo') }
    it { expect(subject.service_name).to eq('ODataDemo') }

    it { expect(subject['ID']).to eq(0) }
    it { expect(subject['Name']).to eq('Bread') }
    it { expect(subject['Description']).to eq('Whole grain bread') }
    it { expect(subject['ReleaseDate']).to eq(DateTime.new(1992,1,1,0,0,0,0)) }
    it { expect(subject['DiscontinuedDate']).to be_nil }
    it { expect(subject['Rating']).to eq(4) }
    it { expect(subject['Price']).to eq(2.5) }

    it { expect {subject['NonExistant']}.to raise_error(ArgumentError) }
    it { expect {subject['NonExistant'] = 5}.to raise_error(ArgumentError) }

    context 'with a complex type property' do
      let(:options) { {
          type:         'ODataDemo.Supplier',
          namespace:    'ODataDemo',
          service_name: 'ODataDemo'
      } }

      let(:subject) { OData::Entity.from_xml(supplier_xml, options) }
      let(:supplier_xml) {
        document = ::Nokogiri::XML(File.open('spec/fixtures/sample_service/supplier_0.xml'))
        document.remove_namespaces!
        document.xpath('//entry').first
      }

      it { expect(subject.name).to eq('Supplier') }
      it { expect(subject.type).to eq('ODataDemo.Supplier') }

      it { expect(subject['Address']).to be_a(OData::ComplexType) }
      it { expect(subject['Address']['Street']).to eq('NE 228th') }
      it { expect(subject['Address']['City']).to eq('Sammamish') }
    end
  end
end
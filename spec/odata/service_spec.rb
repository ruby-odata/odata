require 'spec_helper'

describe OData::Service, vcr: {cassette_name: 'service_specs'} do
  let(:subject) { OData::Service.open('http://services.odata.org/OData/OData.svc') }
  let(:entity_types) { %w{Product FeaturedProduct ProductDetail Category Supplier Person Customer Employee PersonDetail Advertisement} }
  let(:entity_sets) { %w{Products ProductDetails Categories Suppliers Persons PersonDetails Advertisements} }
  let(:entity_set_types) { %w{Product ProductDetail Category Supplier Person PersonDetail Advertisement} }
  let(:complex_types) { %w{Address} }

  describe '.open' do
    it { expect(OData::Service).to respond_to(:open) }
  end

  it 'adds itself to OData::ServiceRegistry on creation' do
    expect(OData::ServiceRegistry['ODataDemo']).to be_nil
    expect(OData::ServiceRegistry['http://services.odata.org/OData/OData.svc']).to be_nil

    service = OData::Service.open('http://services.odata.org/OData/OData.svc')

    expect(OData::ServiceRegistry['ODataDemo']).to eq(service)
    expect(OData::ServiceRegistry['http://services.odata.org/OData/OData.svc']).to eq(service)
  end

  describe 'instance methods' do
    it { expect(subject).to respond_to(:service_url) }
    it { expect(subject).to respond_to(:entity_types) }
    it { expect(subject).to respond_to(:entity_sets) }
    it { expect(subject).to respond_to(:complex_types) }
    it { expect(subject).to respond_to(:namespace) }
  end

  describe '#service_url' do
    it { expect(subject.service_url).to eq('http://services.odata.org/OData/OData.svc') }
  end

  describe '#entity_types' do
    it { expect(subject.entity_types.size).to eq(10) }
    it { expect(subject.entity_types).to eq(entity_types) }
  end

  describe '#entity_sets' do
    it { expect(subject.entity_sets.size).to eq(7) }
    it { expect(subject.entity_sets.keys).to eq(entity_set_types) }
    it { expect(subject.entity_sets.values).to eq(entity_sets) }
  end

  describe '#complex_types' do
    it { expect(subject.complex_types.size).to eq(1) }
    it { expect(subject.complex_types).to eq(complex_types) }
  end

  describe '#namespace' do
    it { expect(subject.namespace).to eq('ODataDemo') }
  end

  describe '#[]' do
    it { expect(subject['Products']).to be_a(OData::EntitySet) }
    it { expect {subject['Nonexistant']}.to raise_error(ArgumentError) }
  end
end
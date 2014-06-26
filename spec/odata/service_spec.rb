require 'spec_helper'

describe OData::Service do
  let(:subject) { OData::Service.open('http://services.odata.org/OData/OData.svc') }
  let(:entity_types) { %w{Product FeaturedProduct ProductDetail Category Supplier Person Customer Employee PersonDetail Advertisement} }
  let(:entity_sets) { %w{Products ProductDetails Categories Suppliers Persons PersonDetails Advertisements} }
  let(:entity_set_types) { %w{Product ProductDetail Category Supplier Person PersonDetail Advertisement} }
  let(:complex_types) { %w{Address} }

  # We're calling this as a private method because there should not be any
  # reasons to have to flush the service registry except in testing.
  after :each do
    OData::ServiceRegistry.instance.send(:flush)
  end

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

  describe '#get' do
    describe 'a set of entities' do
      it { expect(subject.get(::Examples::Product).size).to eq(11) }
      it { expect(subject.get(::Examples::Product).first).to be_instance_of(::Examples::Product) }
      it { expect(subject.get(::Examples::Product).shuffle.first).to be_instance_of(::Examples::Product) }
      it { expect(subject.get(::Examples::Product).last).to be_instance_of(::Examples::Product) }
    end

    describe 'a specific entity by key' do
      it { expect(subject.get(::Examples::Product, {key: 0}).size).to eq(1) }
      it { expect(subject.get(::Examples::Product, {key: 0}).first).to be_instance_of(::Examples::Product) }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.id).to eq(0) }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.name).to eq('Bread') }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.description).to eq('Whole grain bread') }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.release_date).to eq(DateTime.parse('1992-01-01T00:00:00')) }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.discontinued_date).to eq(nil) }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.rating).to eq(4) }
      it { expect(subject.get(::Examples::Product, {key: 0}).first.price).to eq(2.5) }
    end
  end
end
require 'spec_helper'

describe OData::EntitySet, vcr: {cassette_name: 'entity_set_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc')
  end

  let(:subject) { OData::EntitySet.new(options) }
  let(:options) { {
      container: 'DemoService', namespace: 'ODataDemo', name: 'Products',
      type: 'Product'
  } }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject).to respond_to(:type) }
  it { expect(subject).to respond_to(:container) }
  it { expect(subject).to respond_to(:namespace) }
  it { expect(subject).to respond_to(:new_entity) }
  it { expect(subject).to respond_to(:filter) }
  it { expect(subject).to respond_to(:[]) }
  it { expect(subject).to respond_to(:<<) }

  it { expect(subject.name).to eq('Products') }
  it { expect(subject.container).to eq('DemoService') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.type).to eq('Product') }

  describe '#each' do
    it { expect(subject).to respond_to(:each) }
    it { expect(lambda {
      @counter = 0
      subject.each {|entity| @counter += 1}
      @counter
    }.call).to eq(11) }
    it { expect(lambda {
      @entities = []
      subject.each {|entity| @entities << entity}
      @entities
    }.call.shuffle.first).to be_a(OData::Entity) }
  end

  describe '#count' do
    it { expect(subject).to respond_to(:count) }
    it { expect(subject.count).to eq(11) }
  end

  describe '#new_entity' do
    let(:new_entity) { subject.new_entity(properties) }
    let(:release_date) { DateTime.new(2014,7,5) }
    let(:properties) { {
        Name:             'Widget',
        Description:      'Just a simple widget',
        ReleaseDate:      release_date,
        DiscontinuedDate: nil,
        Rating:           4,
        Price:            3.5
    } }

    it { expect(new_entity['ID']).to be_nil }
    it { expect(new_entity['Name']).to eq('Widget') }
    it { expect(new_entity['Description']).to eq('Just a simple widget') }
    it { expect(new_entity['ReleaseDate']).to eq(release_date) }
    it { expect(new_entity['DiscontinuedDate']).to be_nil }
    it { expect(new_entity['Rating']).to eq(4) }
    it { expect(new_entity['Price']).to eq(3.5) }
  end

  describe '#filter' do
    let(:one_entity) { "Name eq 'Bread'" }
    let(:many_entities) { 'Rating eq 3' }

    it { expect(subject.filter(one_entity)).to be_a(Array) }
    it { expect(subject.filter(one_entity).first).to be_a(OData::Entity) }

    it { expect(subject.filter(many_entities)).to be_a(Array) }
    it do
      subject.filter(one_entity).each do |entity|
        expect(entity).to be_a(OData::Entity)
      end
    end
  end

  describe '#[]' do
    let(:existing_entity) { subject[0] }
    let(:nonexistant_entity) { subject[99] }

    it { expect(existing_entity).to be_a(OData::Entity) }
    it { expect(existing_entity['ID']).to eq(0) }

    it { expect(nonexistant_entity).to be_nil }
  end

  describe '#<<' do
    let(:new_entity) { subject.new_entity(properties) }
    let(:bad_entity) { subject.new_entity }
    let(:existing_entity) { subject.first }
    let(:properties) { {
        Name:             'Widget',
        Description:      'Just a simple widget',
        ReleaseDate:      DateTime.now.new_offset(0),
        DiscontinuedDate: nil,
        Rating:           4,
        Price:            3.5
    } }

    describe 'with an existing entity', vcr: {cassette_name: 'entity_set_specs/existing_entry'} do
      it { expect {subject << existing_entity}.to_not raise_error }
    end

    describe 'with a new entity', vcr: {cassette_name: 'entity_set_specs/new_entry'} do
      it do
        expect(new_entity['ID']).to be_nil
        expect {subject << new_entity}.to_not raise_error
        expect(new_entity['ID']).to_not be_nil
        expect(new_entity['ID']).to eq(9999)
      end
    end

    describe 'with a bad entity', vcr: {cassette_name: 'entity_set_specs/bad_entry'} do
      it { expect {subject << bad_entity}.to raise_error(StandardError, 'Something went wrong committing your entity') }
    end
  end
end
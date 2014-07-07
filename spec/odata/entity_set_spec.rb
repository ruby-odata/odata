require 'spec_helper'

describe OData::EntitySet do
  let(:subject) { OData::EntitySet.new(options) }
  let(:options) { {
      container: 'DemoService', namespace: 'ODataDemo', name: 'Products',
      type: 'Product'
  } }

  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc')
  end

  it { expect(subject).to respond_to(:name, :type, :container, :namespace, :new_entity) }

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

    it { expect(subject).to respond_to(:<<) }

    it 'with an existing entity' do
      WebMock.stub_request(:post, 'http://services.odata.org/OData/OData.svc/Products(0)').
          to_return(status: 200, body: File.open('spec/fixtures/sample_service/product_0.xml'))

      expect {subject << existing_entity}.to_not raise_error
    end

    it 'with a new entity' do
      WebMock.stub_request(:post, 'http://services.odata.org/OData/OData.svc/Products').
          to_return(status: 201, body: File.open('spec/fixtures/sample_service/product_9999.xml'))

      expect(new_entity['ID']).to be_nil
      expect {subject << new_entity}.to_not raise_error
      expect(new_entity['ID']).to_not be_nil
      expect(new_entity['ID']).to eq(9999)
    end

    it 'with a bad entity' do
      WebMock.stub_request(:post, 'http://services.odata.org/OData/OData.svc/Products').
          to_return(status: 400, body: nil)

      expect {subject << bad_entity}.to raise_error(StandardError, 'Something went wrong committing your entity')
    end
  end
end
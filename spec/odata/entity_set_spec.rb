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

  # Basic Instance Methods
  it { expect(subject).to respond_to(:name, :type, :container, :namespace) }

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
  end

  describe '#count' do
    it { expect(subject).to respond_to(:count) }
    it { expect(subject.count).to eq(11) }
  end
end
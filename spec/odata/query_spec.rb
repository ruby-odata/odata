require 'spec_helper'

describe OData::Query do
  let(:subject) { OData::Query.new(entity_set) }
  let(:entity_set) { OData::EntitySet.new(options) }
  let(:options) { {
      container: 'DemoService', namespace: 'ODataDemo', name: 'Products',
      type: 'Product'
  } }

  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc')
  end

  it { expect(subject).to respond_to(:to_s) }
  it { expect(subject.to_s).to eq('Products')}

  describe '#where' do
    it { expect(subject).to respond_to(:where) }
  end

  describe '#and' do
    it { expect(subject).to respond_to(:and) }
  end

  describe '#or' do
    it { expect(subject).to respond_to(:or) }
  end

  describe '#skip' do
    it { expect(subject).to respond_to(:skip) }
    it { expect(subject.skip(5)).to eq(subject) }
    it 'properly formats query with skip specified' do
      subject.skip(5)
      expect(subject.to_s).to eq('Products?$skip=5')
    end
  end

  describe '#limit' do
    it { expect(subject).to respond_to(:limit) }
    it { expect(subject.limit(5)).to eq(subject) }
    it 'properly formats query with limit specified' do
      subject.limit(5)
      expect(subject.to_s).to eq('Products?$top=5')
    end
  end

  describe '#include_count' do
    it { expect(subject).to respond_to(:include_count) }
    it { expect(subject.include_count).to eq(subject) }
    it 'properly formats query with include_count specified' do
      subject.include_count
      expect(subject.to_s).to eq('Products?$inlinecount=allpages')
    end
  end

  describe '#select' do
    it { pending; fail }
  end

  describe '#expand' do
    it { pending; fail }
  end

  describe '#order_by' do
    it { pending; fail }
  end
end
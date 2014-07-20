require 'spec_helper'

describe OData::Query, vcr: {cassette_name: 'query_specs'} do
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

  it { expect(subject).to respond_to(:[]) }
  describe '#[]' do
    it { expect(subject[:Name]).to be_a(OData::Query::Criteria) }
    it { expect(subject[:Name].property).to eq(:Name) }
  end

  it { expect(subject).to respond_to(:where) }
  describe '#where' do
    let(:criteria) { subject[:Name].eq('Bread') }
    let(:query_string) { "Products?$filter=Name eq 'Bread'" }

    it { expect(subject.where(criteria)).to eq(subject) }
    it { expect(subject.where(criteria).to_s).to eq(query_string) }
  end

  #it { expect(subject).to respond_to(:and) }
  describe '#and' do
    it { pending; fail }
  end

  #it { expect(subject).to respond_to(:or) }
  describe '#or' do
    it { pending; fail }
  end

  it { expect(subject).to respond_to(:skip) }
  describe '#skip' do
    it { expect(subject.skip(5)).to eq(subject) }
    it 'properly formats query with skip specified' do
      subject.skip(5)
      expect(subject.to_s).to eq('Products?$skip=5')
    end
  end

  it { expect(subject).to respond_to(:limit) }
  describe '#limit' do

    it { expect(subject.limit(5)).to eq(subject) }
    it 'properly formats query with limit specified' do
      subject.limit(5)
      expect(subject.to_s).to eq('Products?$top=5')
    end
  end

  it { expect(subject).to respond_to(:include_count) }
  describe '#include_count' do
    it { expect(subject.include_count).to eq(subject) }
    it 'properly formats query with include_count specified' do
      subject.include_count
      expect(subject.to_s).to eq('Products?$inlinecount=allpages')
    end
  end

  it { expect(subject).to respond_to(:select) }
  describe '#select' do
    it { expect(subject.select(:Name, :Price)).to eq(subject) }
    it 'properly formats query with select operation specified' do
      subject.select(:Name, :Price)
      expect(subject.to_s).to eq('Products?$select=Name,Price')
    end
  end

  it { expect(subject).to respond_to(:expand) }
  describe '#expand' do
    it { expect(subject.expand(:Supplier)).to eq(subject) }
    it 'properly formats query with expand operation specified' do
      subject.expand(:Supplier)
      expect(subject.to_s).to eq('Products?$expand=Supplier')
    end
  end

  it { expect(subject).to respond_to(:order_by) }
  describe '#order_by' do
    it { expect(subject.order_by(:Name, :Price)).to eq(subject) }
    it 'properly formats query with orderby operation specified' do
      subject.order_by(:Name, :Price)
      expect(subject.to_s).to eq('Products?$orderby=Name,Price')
    end
  end

  it { expect(subject).to respond_to(:execute) }
  describe '#execute' do
    it { expect(subject.execute).to be_a(OData::Query::Result) }
  end
end
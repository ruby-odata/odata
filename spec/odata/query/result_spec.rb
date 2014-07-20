require 'spec_helper'

describe OData::Query::Result, vcr: {cassette_name: 'query/result_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc')
  end

  let(:subject) { query.execute }
  let(:query) { OData::Query.new(entity_set) }
  let(:entity_set) { OData::ServiceRegistry['ODataDemo']['Products'] }

  it { expect(subject).to respond_to(:each) }
  describe '#each' do
    it 'returns just OData::Entities of the right type' do
      subject.each do |entity|
        expect(entity).to be_a(OData::Entity)
        expect(entity.type).to eq('Product')
      end
    end
  end
end
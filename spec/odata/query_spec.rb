require 'spec_helper'

describe OData::Query do
  let(:subject) { OData::Query.new('Products') }

  it { expect(subject).to respond_to(:<<) }
  it { expect(subject).to respond_to(:to_s) }

  it { expect(subject.to_s).to eq('Products')}

  it 'handles pagination operations' do
    skip_criteria = OData::Query::Criteria.new(operation: 'skip', argument: 5)
    top_criteria = OData::Query::Criteria.new(operation: 'top', argument: 5)
    subject << top_criteria
    subject << skip_criteria
    expect(subject.to_s).to eq('Products?$skip=5&$top=5')
  end

  it 'handles inline_count operations' do
    criteria = OData::Query::Criteria.new(operation: 'inline_count', argument: 'allpages')
    subject << criteria
    expect(subject.to_s).to eq('Products?$inlinecount=allpages')
  end

  it 'handles select operations' do
    criteria1 = OData::Query::Criteria.new(operation: 'select', argument: 'Name')
    criteria2 = OData::Query::Criteria.new(operation: 'select', argument: 'Rating')
    criteria3 = OData::Query::Criteria.new(operation: 'select', argument: 'Price')
    subject << criteria1
    subject << criteria2
    subject << criteria3
    expect(subject.to_s).to eq('Products?$select=Name,Rating,Price')
  end

  it 'handles expand operations' do
    criteria1 = OData::Query::Criteria.new(operation: 'expand', argument: 'Supplier')
    criteria2 = OData::Query::Criteria.new(operation: 'expand', argument: 'ProductDetail')
    subject << criteria1
    subject << criteria2
    expect(subject.to_s).to eq('Products?$expand=Supplier,ProductDetail')
  end

  it 'handles order_by operations' do
    criteria1 = OData::Query::Criteria.new(operation: 'order_by', argument: 'Price')
    criteria2 = OData::Query::Criteria.new(operation: 'order_by', argument: 'Rating desc')
    subject << criteria1
    subject << criteria2
    expect(subject.to_s).to eq('Products?$orderby=Price,Rating desc')
  end

  it 'handles filter operations' do
    criteria1 = OData::Query::Criteria.new(operation: 'filter', argument: 'Rating gt 2')
    criteria2 = OData::Query::Criteria.new(operation: 'filter', argument: 'Price lt 15')
    subject << criteria1
    subject << criteria2
    expect(subject.to_s).to eq('Products?$filter=Rating gt 2 and Price lt 15')
  end
end
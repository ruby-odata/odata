require 'spec_helper'

describe OData::Query::Criteria do
  let(:subject) { OData::Query::Criteria.new(operation: 'filter', argument: "Name eq 'Bread'") }
  let(:valid_operations) { [:filter, :order_by, :skip, :top, :select, :expand, :inline_count] }

  it { expect(subject).to respond_to(:operation) }
  it { expect(subject).to respond_to(:argument) }

  it { expect(subject.operation).to eq(:filter) }
  it { expect(subject.argument).to eq("Name eq 'Bread'")}

  it 'should require operation option' do
    expect {
      OData::Query::Criteria.new(argument: 'test')
    }.to raise_error(ArgumentError, 'Missing required option: operation')
  end

  it 'should require argument option' do
    expect {
      OData::Query::Criteria.new(operation: 'filter')
    }.to raise_error(ArgumentError, 'Missing required option: argument')
  end

  it 'should validate operation option' do
    valid_operations.each do |operation|
      expect {
        OData::Query::Criteria.new(operation: operation, argument: 'test')
      }.to_not raise_error
    end

    expect {
      OData::Query::Criteria.new(operation: 'invalid', argument: 'test')
    }.to raise_error(ArgumentError, 'Operation not supported: invalid')
  end
end
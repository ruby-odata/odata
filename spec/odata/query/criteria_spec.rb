require 'spec_helper'

describe OData::Query::Criteria do
  let(:subject) { OData::Query::Criteria.new(property: :Name) }

  it { expect(subject).to respond_to(:property) }
  it { expect(subject.property).to eq(:Name)}

  it { expect(subject).to respond_to(:operator) }
  it { expect(subject).to respond_to(:value) }
  it { expect(subject).to respond_to(:to_s) }
end
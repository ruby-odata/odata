require 'spec_helper'

describe OData::Properties::Guid do
  let(:guid) { SecureRandom.uuid }
  let(:guid2) { SecureRandom.uuid }
  let(:subject) { OData::Properties::Guid.new('Stringy', guid) }

  it { expect(subject.type).to eq('Edm.Guid') }
  it { expect(subject.value).to eq(guid)}

  it { expect(lambda {
    subject.value = guid2
    subject.value
  }.call).to eq(guid2) }
end
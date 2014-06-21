require 'spec_helper'

describe OData::Properties::Boolean do
  let(:truthy1) { OData::Properties::Boolean.new('Truthy', 'true') }
  let(:truthy2) { OData::Properties::Boolean.new('Truthy', '1') }
  let(:falsey1) { OData::Properties::Boolean.new('Falsey', 'false') }
  let(:falsey2) { OData::Properties::Boolean.new('Falsey', '0') }
  let(:nily) { OData::Properties::Boolean.new('Nily', nil) }

  it { expect(truthy1.value).to eq(true) }
  it { expect(truthy2.value).to eq(true) }

  it { expect(falsey1.value).to eq(false) }
  it { expect(falsey2.value).to eq(false) }

  it { expect(nily.value).to eq(nil) }
end
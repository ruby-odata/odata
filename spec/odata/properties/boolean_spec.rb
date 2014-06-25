require 'spec_helper'

describe OData::Properties::Boolean do
  let(:truthy1) { OData::Properties::Boolean.new('Truthy', 'true') }
  let(:truthy2) { OData::Properties::Boolean.new('Truthy', '1') }
  let(:falsey1) { OData::Properties::Boolean.new('Falsey', 'false') }
  let(:falsey2) { OData::Properties::Boolean.new('Falsey', '0') }
  let(:nily) { OData::Properties::Boolean.new('Nily', nil) }

  it { expect(truthy1.type).to eq('Edm.Boolean') }
  it { expect(truthy1.value).to eq(true) }
  it { expect(truthy2.value).to eq(true) }

  it { expect(falsey1.value).to eq(false) }
  it { expect(falsey2.value).to eq(false) }

  it { expect(nily.value).to eq(nil) }

  it { expect {truthy1.value = 'bad'}.to raise_error(ArgumentError) }

  describe 'setting to false' do
    let(:subject) { OData::Properties::Boolean.new('Truthy', 'true') }

    it { expect(subject.value).to eq(true) }

    it { expect(lambda {
      subject.value = false
      subject.value
    }.call).to eq(false) }

    it { expect(lambda {
      subject.value = 'false'
      subject.value
    }.call).to eq(false) }

    it { expect(lambda {
      subject.value = '0'
      subject.value
    }.call).to eq(false) }
  end

  describe 'setting to true' do
    let(:subject) { OData::Properties::Boolean.new('Falsey', 'false') }

    it { expect(subject.value).to eq(false) }

    it { expect(lambda {
      subject.value = true
      subject.value
    }.call).to eq(true) }

    it { expect(lambda {
      subject.value = 'true'
      subject.value
    }.call).to eq(true) }

    it { expect(lambda {
      subject.value = '1'
      subject.value
    }.call).to eq(true) }
  end
end
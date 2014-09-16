require 'spec_helper'

describe OData::Properties::Binary do
  let(:subject) { OData::Properties::Binary.new('On', '1') }

  it { expect(subject.type).to eq('Edm.Binary') }
  it { expect(subject.value).to eq(1) }

  it { expect {subject.value = 'bad'}.to raise_error(ArgumentError) }

  it { expect(subject.url_value).to eq("binary'1'") }

  describe 'setting to 0' do
    it { expect(lambda {
      subject.value = 0
      subject.value
    }.call).to eq(0) }

    it { expect(lambda {
      subject.value = false
      subject.value
    }.call).to eq(0) }

    it { expect(lambda {
      subject.value = '0'
      subject.value
    }.call).to eq(0) }
  end

  describe 'setting to 1' do
    let(:subject) { OData::Properties::Binary.new('On', '0') }

    it { expect(subject.value).to eq(0) }

    it { expect(lambda {
      subject.value = 1
      subject.value
    }.call).to eq(1) }

    it { expect(lambda {
      subject.value = true
      subject.value
    }.call).to eq(1) }

    it { expect(lambda {
      subject.value = '1'
      subject.value
    }.call).to eq(1) }
  end
end
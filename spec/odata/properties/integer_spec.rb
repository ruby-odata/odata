require 'spec_helper'

describe OData::Properties::Integer do
  let(:subject) { OData::Properties::Integer.new('Integer', '32') }
  let(:subject16) { OData::Properties::Int16.new('Int16', '32') }
  let(:subject32) { OData::Properties::Int32.new('Int32', '32') }
  let(:subject64) { OData::Properties::Int64.new('Int64', '32') }
  let(:subjectbyte) { OData::Properties::Byte.new('Byte', '32') }
  let(:subjectsbyte) { OData::Properties::SByte.new('SByte', '32') }

  it { expect(subject.type).to eq('Edm.Int64') }
  it { expect(subject.value).to eq(32) }

  it { expect(subject16.type).to eq('Edm.Int16') }
  it { expect(subject16.value).to eq(32) }

  it { expect(subject32.type).to eq('Edm.Int32') }
  it { expect(subject32.value).to eq(32) }

  it { expect(subject64.type).to eq('Edm.Int64') }
  it { expect(subject64.value).to eq(32) }

  it { expect(subjectbyte.type).to eq('Edm.Byte') }
  it { expect(subjectbyte.value).to eq(32) }

  it { expect(subjectsbyte.type).to eq('Edm.SByte') }
  it { expect(subjectsbyte.value).to eq(32) }

  describe '#value=' do
    before(:example) do
      subject.value = 128
      subject16.value = 128
      subject32.value = 128
      subject64.value = 128
      subjectbyte.value = 12
      subjectsbyte.value = 12
    end

    it { expect(subject.value).to eq(128) }
    it { expect(subject16.value).to eq(128) }
    it { expect(subject32.value).to eq(128) }
    it { expect(subject64.value).to eq(128) }
    it { expect(subjectbyte.value).to eq(12) }
    it { expect(subjectsbyte.value).to eq(12) }
  end
end
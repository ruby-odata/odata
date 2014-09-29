require 'spec_helper'

describe OData::Association::End do
  let(:subject) { OData::Association::End.new(options) }
  let(:options) { { entity_type: 'Product', multiplicity: '1' } }

  it { expect(subject).to respond_to(:entity_type) }
  it { expect(subject).to respond_to(:multiplicity) }

  describe '#new' do
    it 'raises error without entity_type option' do
      expect {
        OData::Association::End.new(multiplicity: '1')
      }.to raise_error(ArgumentError)
    end

    it 'raises error without multiplicity option' do
      expect {
        OData::Association::End.new(entity_type: 'Product')
      }.to raise_error(ArgumentError)
    end

    it 'raises error with invalid multiplicity option' do
      expect {
        OData::Association::End.new(entity_type: 'Product', multiplicity: :invalid)
      }.to raise_error(ArgumentError)
    end
  end

  it { expect(OData::Association::End).to respond_to(:multiplicity_map) }
  it { expect(OData::Association::End.multiplicity_map['1']).to eq(:one) }
  it { expect(OData::Association::End.multiplicity_map['*']).to eq(:many) }
  it { expect(OData::Association::End.multiplicity_map['0..1']).to eq(:zero_to_one) }
end
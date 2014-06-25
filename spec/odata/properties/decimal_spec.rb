require 'spec_helper'

describe OData::Properties::Decimal do
  let(:subject) { OData::Properties::Decimal.new('Decimal', '678.90325') }

  it { expect(subject.type).to eq('Edm.Decimal') }
  it { expect(subject.value).to eq(BigDecimal('678.90325')) }

  it { expect { subject.value = BigDecimal((7.9 * (10**28)) + 1) }.to raise_error(ArgumentError) }
  it { expect { subject.value = BigDecimal((-7.9 * (10**28)) - 1) }.to raise_error(ArgumentError) }

  it { expect(lambda {
    subject.value = '19.89043256'
    subject.value
  }.call).to eq(BigDecimal('19.89043256')) }

  it { expect(lambda {
    subject.value = BigDecimal('19.89043256')
    subject.value
  }.call).to eq(BigDecimal('19.89043256')) }
end
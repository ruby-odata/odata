require 'spec_helper'

describe OData::Properties::Float do
  describe 'double precision' do
    let(:subject) { OData::Properties::Double.new('Float', '678.90325') }

    it { expect(subject.type).to eq('Edm.Double') }
    it { expect(subject.value).to eq(678.90325) }

    it { expect { subject.value = (1.7 * (10**308) * 2) }.to raise_error(ArgumentError) }
    it { expect { subject.value = (-1.7 * (10**308) * 2) }.to raise_error(ArgumentError) }

    it { expect(lambda {
      subject.value = '19.89043256'
      subject.value
    }.call).to eq(19.89043256) }

    it { expect(lambda {
      subject.value = 19.89043256
      subject.value
    }.call).to eq(19.89043256) }
  end

  describe 'single precision' do
    let(:subject) { OData::Properties::Single.new('Float', '678.90325') }

    it { expect(subject.type).to eq('Edm.Single') }
    it { expect(subject.value).to eq(678.90325) }

    it { expect { subject.value = (3.4 * (10**38) * 2) }.to raise_error(ArgumentError) }
    it { expect { subject.value = (-3.4 * (10**38) * 2) }.to raise_error(ArgumentError) }

    it { expect(lambda {
      subject.value = '19.89043256'
      subject.value
    }.call).to eq(19.89043256) }

    it { expect(lambda {
      subject.value = 19.89043256
      subject.value
    }.call).to eq(19.89043256) }
  end
end
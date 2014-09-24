require 'spec_helper'

describe OData::PropertyRegistry do
  let(:subject) { OData::PropertyRegistry }

  it { expect(subject).to respond_to(:add) }
  it { expect(subject).to respond_to(:[]) }

  describe '#add' do
    before(:each) do
      subject.add('Edm.Guid', OData::Properties::Guid)
    end

    it { expect(subject['Edm.Guid']).to eq(OData::Properties::Guid) }
  end
end
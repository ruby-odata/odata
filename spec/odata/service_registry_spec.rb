require 'spec_helper'

describe OData::ServiceRegistry, vcr: {cassette_name: 'service_registry_specs'} do
  let(:subject) { OData::ServiceRegistry }
  let(:sample_service) { OData::Service.open('http://services.odata.org/OData/OData.svc') }

  it { expect(subject).to respond_to(:add) }
  it { expect(subject).to respond_to(:[]) }

  describe '#add' do
    before :each do
      subject.add(sample_service)
    end

    it { expect(subject[sample_service.namespace]).to eq(sample_service) }
    it { expect(subject[sample_service.service_url]).to eq(sample_service) }
  end
end
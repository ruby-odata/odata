require 'spec_helper'

describe OData::ServiceRegistry do
  let(:subject) { OData::ServiceRegistry }
  let(:sample_service) { OData::Service.open('http://services.odata.org/OData/OData.svc') }

  # We're calling this as a private method because there should not be any
  # reasons to have to flush the service registry except in testing.
  after :each do
    OData::ServiceRegistry.instance.send(:flush)
  end

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
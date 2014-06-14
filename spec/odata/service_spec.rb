require 'spec_helper'

describe OData::Service do
  it { expect(OData::Service).to respond_to(:open) }

  context 'working with a sample service' do
    let(:subject) { OData::Service.open('http://sample.local/odata/odata.svc') }
  end
end
require 'spec_helper'

describe OData::ComplexType, vcr: {cassette_name: 'complex_type_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::ComplexType.new(name: 'Address', service: service) }
  let(:service) { OData::ServiceRegistry['ODataDemo'] }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject).to respond_to(:namespace) }
  it { expect(subject).to respond_to(:property_names) }
  it { expect(subject).to respond_to(:[]) }
  it { expect(subject).to respond_to(:[]=) }

  describe 'is properly parsed from service metadata' do
    it { expect(subject.name).to eq('Address') }
    it { expect(subject.namespace).to eq('ODataDemo') }
    it { expect(subject.property_names).to eq(%w{Street City State ZipCode Country}) }

    it { expect(subject['Street']).to be_nil }
    it { expect(subject['City']).to be_nil }
    it { expect(subject['State']).to be_nil }
    it { expect(subject['ZipCode']).to be_nil }
    it { expect(subject['Country']).to be_nil }

    it { subject['Street'] = 'Test'; expect(subject['Street']).to eq('Test') }
    it { subject['City'] = 'Test'; expect(subject['City']).to eq('Test') }
    it { subject['State'] = 'Test'; expect(subject['State']).to eq('Test') }
    it { subject['ZipCode'] = 'Test'; expect(subject['ZipCode']).to eq('Test') }
    it { subject['Country'] = 'Test'; expect(subject['Country']).to eq('Test') }
  end
end
require 'spec_helper'

describe OData::EntitySet do
  let(:subject) { OData::EntitySet.new(options) }
  let(:options) { {
      container: 'DemoService', namespace: 'ODataDemo', name: 'Products',
      type: 'Product'
  } }

  it { expect(subject).to respond_to(:name, :type, :container, :namespace) }

  it { expect(subject.name).to eq('Products') }
  it { expect(subject.container).to eq('DemoService') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.type).to eq('Product') }

  describe 'enumerable behavior' do
    it { expect(subject).to respond_to(:each) }
  end
end
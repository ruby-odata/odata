require 'spec_helper'
require 'examples/product_model'

describe OData::Model do
  describe 'class methods' do
    it { expect(::Examples::Product).to respond_to(:model_name) }
    it { expect(::Examples::Product.model_name).to eq('Product') }
    it { expect(::Examples::Product.odata_name).to eq('Products') }
  end

  describe 'defining properties' do
    let(:subject) { ::Examples::Product.new }

    it { expect(subject).to respond_to(:id) }
    it { expect(subject).to respond_to(:name) }
    it { expect(subject).to respond_to(:description) }
    it { expect(subject).to respond_to(:release_date) }
    it { expect(subject).to respond_to(:discontinued_date) }
    it { expect(subject).to respond_to(:rating) }
    it { expect(subject).to respond_to(:price) }

    it { expect(::Examples::Product).to respond_to(:primary_key) }
    it { expect(::Examples::Product.primary_key).to eq(:id)}
  end
end
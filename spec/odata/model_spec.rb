require 'spec_helper'
require 'examples/product_model'

describe OData::Model do
  describe 'defining properties' do
    let(:subject) { Product.new }

    it { expect(subject).to respond_to(:id) }
    it { expect(subject).to respond_to(:name) }
    it { expect(subject).to respond_to(:description) }
    it { expect(subject).to respond_to(:release_date) }
    it { expect(subject).to respond_to(:discontinued_date) }
    it { expect(subject).to respond_to(:rating) }
    it { expect(subject).to respond_to(:price) }

    it { expect(Product).to respond_to(:primary_key) }
    it { expect(Product.primary_key).to eq(:id)}
  end
end
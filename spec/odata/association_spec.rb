require 'spec_helper'

describe OData::Association do
  let(:subject) { OData::Association.new(name: 'Product_Categories_Category_Products') }
  let(:product_end) { nil }
  let(:category_end) { nil }

  it { expect(subject).to respond_to(:name) }

  it { expect(subject).to respond_to(:ends) }
  it { expect(subject.ends).to be_a(Hash) }

  context 'when initialized' do
    let(:subject) do
      OData::Association.new(name: 'Product_Categories_Category_Products',
                             ends: {
                                 'Category_Products' => category_end,
                                 'Product_Categories' => product_end
                             })
    end

    it { expect(subject.name).to eq('Product_Categories_Category_Products') }
    it { expect(subject.ends.size).to eq(2) }
  end

  context 'when initialized with too many ends' do
    let(:subject) do
      OData::Association.new(name: 'Product_Categories_Category_Products',
                             ends: {
                                 'Category_Products' => category_end,
                                 'Product_Categories' => product_end,
                                 'Invalid' => category_end
                             })
    end

    it { expect { subject }.to raise_error(ArgumentError) }
  end

  context 'when initialized without a name' do
    let(:subject) do
      OData::Association.new
    end

    it { expect { subject }.to raise_error(ArgumentError) }
  end
end
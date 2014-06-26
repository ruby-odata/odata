require 'spec_helper'

describe OData::Property do
  let(:subject) { OData::Property.new('PropertyName', '1') }
  let(:good_comparison) { OData::Property.new('GoodComparison', '1') }
  let(:bad_comparison) { OData::Property.new('BadComparison', '2') }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject.name).to eq('PropertyName') }

  it { expect(subject).to respond_to(:value) }
  it { expect(subject.value).to eq('1') }

  it { expect(subject).to respond_to(:type) }
  it { expect(lambda {subject.type}).to raise_error(NotImplementedError) }

  it { expect(subject).to respond_to(:allows_nil?) }
  it { expect(subject.allows_nil?).to eq(true) }

  it { expect(subject).to respond_to(:concurrency_mode) }
  it { expect(subject.concurrency_mode).to eq(:none) }

  it { expect(subject).to respond_to(:==) }
  it { expect(subject == good_comparison).to eq(true) }
  it { expect(subject == bad_comparison).to eq(false) }
end
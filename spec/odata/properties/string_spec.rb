require 'spec_helper'

describe OData::Properties::String do
  let(:subject) { OData::Properties::String.new('Stringy', 'This is an example') }

  it { expect(subject.type).to eq('Edm.String') }
  it { expect(subject.value).to eq('This is an example')}

  it { expect(lambda {
    subject.value = 'Another example'
    subject.value
  }.call).to eq('Another example') }

  it { expect(lambda {
    subject.value = nil
    subject.value
  }.call).to eq(nil) }

  describe '#is_unicode?' do
    let(:not_unicode) { OData::Properties::String.new('Stringy', 'This is an example', unicode: false) }

    it { expect(subject.is_unicode?).to eq(true) }
    it { expect(not_unicode.is_unicode?).to eq(false) }

    it { expect(subject.value.encoding).to eq(Encoding::UTF_8) }
    it { expect(not_unicode.value.encoding).to eq(Encoding::ASCII) }
  end

  describe 'when #allows_nil? is false' do
    let(:subject) { OData::Properties::String.new('Stringy', 'This is an example', allows_nil: false) }

    it { expect {subject.value = nil}.to raise_error(ArgumentError) }
    it { expect {subject.value = 'Test'}.not_to raise_error }
  end
end
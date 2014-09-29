require 'spec_helper'

describe OData::Query::Criteria do
  let(:string_property) { OData::Properties::String.new(:Name, nil) }
  let(:integer_property) { OData::Properties::Integer.new(:Name, nil) }
  let(:subject) { OData::Query::Criteria.new(property: string_property) }

  it { expect(subject).to respond_to(:property) }
  it { expect(subject.property).to eq(string_property)}

  it { expect(subject).to respond_to(:operator) }
  it { expect(subject).to respond_to(:value) }
  it { expect(subject).to respond_to(:to_s) }

  it { expect(subject).to respond_to(:eq) }
  it { expect(subject).to respond_to(:ne) }
  it { expect(subject).to respond_to(:gt) }
  it { expect(subject).to respond_to(:ge) }
  it { expect(subject).to respond_to(:lt) }
  it { expect(subject).to respond_to(:le) }

  describe 'operator method' do
    it '#eq sets up criteria properly' do
      criteria = subject.eq('Bread')
      expect(criteria).to eq(subject)
      expect(criteria.operator).to eq(:eq)
      expect(criteria.value).to eq('Bread')
      expect(criteria.to_s).to eq("Name eq 'Bread'")
    end

    it '#ne sets up criteria properly' do
      criteria = subject.ne('Bread')
      expect(criteria).to eq(subject)
      expect(criteria.operator).to eq(:ne)
      expect(criteria.value).to eq('Bread')
      expect(criteria.to_s).to eq("Name ne 'Bread'")
    end

    it '#gt sets up criteria properly' do
      subject = OData::Query::Criteria.new(property: integer_property)

      criteria = subject.gt(5)
      expect(criteria).to eq(subject)
      expect(criteria.operator).to eq(:gt)
      expect(criteria.value).to eq(5)
      expect(criteria.to_s).to eq('Name gt 5')
    end

    it '#ge sets up criteria properly' do
      subject = OData::Query::Criteria.new(property: integer_property)

      criteria = subject.ge(5)
      expect(criteria).to eq(subject)
      expect(criteria.operator).to eq(:ge)
      expect(criteria.value).to eq(5)
      expect(criteria.to_s).to eq('Name ge 5')
    end

    it '#lt sets up criteria properly' do
      subject = OData::Query::Criteria.new(property: integer_property)

      criteria = subject.lt(5)
      expect(criteria).to eq(subject)
      expect(criteria.operator).to eq(:lt)
      expect(criteria.value).to eq(5)
      expect(criteria.to_s).to eq('Name lt 5')
    end

    it '#le sets up criteria properly' do
      subject = OData::Query::Criteria.new(property: integer_property)

      criteria = subject.le(5)
      expect(criteria).to eq(subject)
      expect(criteria.operator).to eq(:le)
      expect(criteria.value).to eq(5)
      expect(criteria.to_s).to eq('Name le 5')
    end
  end
end
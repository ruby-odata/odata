require 'spec_helper'

describe OData::Properties::DateTimeOffset do
  let(:subject) { OData::Properties::DateTimeOffset.new('DateTime', '2000-01-01T16:00:00.000Z-09:00') }
  let(:new_datetime) { DateTime.strptime('2004-05-01T14:32:00.000Z+02:00', '%Y-%m-%dT%H:%M:%S.%LZ%:z') }

  it { expect(subject.type).to eq('Edm.DateTimeOffset') }
  it { expect(subject.value).to eq(DateTime.strptime('2000-01-01T16:00:00.000Z-09:00', '%Y-%m-%dT%H:%M:%S.%LZ%:z')) }

  it { expect {subject.value = 'bad'}.to raise_error(ArgumentError) }

  it { expect(lambda {
    subject.value = new_datetime
    subject.value
  }.call).to eq(new_datetime) }
end
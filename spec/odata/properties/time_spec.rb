require 'spec_helper'

describe OData::Properties::Time do
  let(:subject) { OData::Properties::Time.new('Timely', '21:00:00-08:00') }

  it { expect(subject.type).to eq('Edm.Time') }
  it { expect(subject.value).to eq(Time.strptime('21:00:00-08:00', '%H:%M:%S%:z')) }

  it { expect {subject.value = 'bad'}.to raise_error(ArgumentError) }

  it { expect(lambda {
    subject.value = Time.strptime('13:22:12+04:00', '%H:%M:%S%:z')
    subject.value
  }.call).to eq(Time.strptime('13:22:12+04:00', '%H:%M:%S%:z'))}
end
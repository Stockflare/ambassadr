# This spec class uses the Etcd HTTP API as its own Micro-service to test
# the Transport class. Bit confusing, but I'm sure you get the picture

class Services < Ambassadr::Services.root!
end

describe Services do

  let(:klass) { Services::Store }

  let(:call) { :upgrade }

  let(:path) { '/services/store' }

  let(:host) { Ambassadr::Container.new.hostname }

  let(:etcd) { ENV['ETCD_URL'] }

  before { Ambassadr.etcd.set "#{path}/#{host}", value: etcd }

  subject { klass.new(:v2, :keys).send(call) }

  it { should be_an_instance_of Services::Transport }

  specify { expect(subject.host).to eq etcd }

  describe 'when all hosts have been called' do

    specify { expect { subject.host && subject.host }.to raise_error(Ambassadr::Services::Errors::HttpError) }

    specify { expect { subject.host && subject.host }.to raise_error { |ex| expect(ex.code).to eq 500 } }

    specify { expect { subject.host && subject.host }.to raise_error("no hosts left for #{path}") }

  end

  describe 'when a host is unavailable' do

    before { Ambassadr.etcd.delete "#{path}/#{host}" }

    specify { expect { subject.host }.to raise_error(Ambassadr::Services::Errors::HttpError) }

    specify { expect { subject.host }.to raise_error { |ex| expect(ex.code).to eq 503 } }

    specify { expect { subject.host }.to raise_error("no available hosts for #{path}") }

  end

  describe 'when a path is not found (404 from etcd)' do

    subject { klass.new(:does, :not, :exist) }

    let(:value) { Faker::Internet.ip_v4_address }

    specify { expect { subject.update({ value: value }).response }.to raise_error(Ambassadr::Services::Errors::HttpError) }

    specify { expect { subject.update({ value: value }).response }.to raise_error { |ex| expect(ex.code).to eq 404 } }

    specify { expect { subject.update({ value: value }).response }.to raise_error { |ex| expect(ex.response).to be_an_instance_of Ambassadr::Services::Response } }

    specify { expect { subject.update({ value: value }).response }.to raise_error(/404/) }

  end

  describe 'using transport to set a new etcd key' do

    let(:key) { Faker::Internet.domain_word }

    subject { klass.new(:v2, :keys, key) }

    let(:value) { Faker::Internet.ip_v4_address }

    before { subject.update({ value: value }).response }

    specify { expect(Ambassadr.etcd.get("/#{key}").value).to eq value }

  end

  describe 'using transport to get an existing etcd key' do

    let(:key) { Faker::Internet.domain_word }

    let(:value) { Faker::Internet.ip_v4_address }

    before { Ambassadr.etcd.set("/#{key}", value: value, ttl: 10) }

    subject { klass.new(:v2, :keys) }

    specify { expect(subject.send(key).response.node.value).to eq value }

  end

  after { Ambassadr.etcd.delete path, recursive: true }

end

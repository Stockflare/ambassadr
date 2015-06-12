# This spec class uses the Etcd HTTP API as its own Micro-service to test
# the Transport class.

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

  describe 'using transport to set a new etcd key' do

    let(:key) { Faker::Internet.domain_word }

    subject { klass.new(:v2, :keys, key) }

    let(:value) { Faker::Internet.ip_v4_address }

    before { @response = subject.update({ value: value, ttl: 10 }).response }

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

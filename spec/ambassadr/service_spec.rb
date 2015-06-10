class Services < Ambassadr::Services.root!
end

describe Services do

  let(:root) { '/services' }

  specify { expect(Services._path).to eq root }

  specify { expect(Services::Some::Other::Service._path).to eq "#{root}/some/other/service" }

  describe 'a simple call transport receiver' do

    let(:path) { '/services/user' }

    let(:call) { :upgrade }

    specify { expect(Services::Transport).to receive(:new).with("#{path}/#{call}") }

    after { Services::User.send(call) }

  end

  describe 'a contextual transport receiver' do

    let(:prefix) { :admins }

    let(:id) { Random.rand(12345) }

    let(:path) { "/services/user/#{prefix}/#{id}" }

    let(:call) { :activate }

    let(:args) { [] }

    subject { Services::User(prefix, id) }

    it { should respond_to(:update) }

    it { should respond_to(:delete) }

    specify { expect(Services::Transport).to receive(:new).with("#{path}/#{call}") }

    describe 'an update' do

      let(:call) { :update }

      let(:opts) { { name: Faker::Name.name } }

      let(:args) { [opts] }

      specify { expect(Services::Transport).to receive(:new).with(path, opts, hash_including(method: :patch)) }

    end

    describe 'a delete' do

      let(:call) { :delete }

      let(:opts) { {} }

      let(:args) { [opts] }

      specify { expect(Services::Transport).to receive(:new).with(path, {}, hash_including(method: :delete)) }

    end

    after { subject.send(call, *args) }

  end

  # describe 'a #find call' do
  #
  #   let(:where) { { name: 'david' } }
  #
  #   subject { Internal::User.find(where) }
  #
  #   it { should be_an_instance_of Ambassadr::Service::Transport }
  #
  #   specify { expect(subject.path).to eq '/internal/user' }
  #
  #   specify { expect(subject.query).to eq 'name=david' }
  #
  #   specify { expect(subject.method).to eq :get }
  #
  # end
  #
  # describe 'a #get call' do
  #
  #   let(:id) { 1 }
  #
  #   subject { Internal::User.get(id) }
  #
  #   it { should be_an_instance_of Ambassadr::Service::Transport }
  #
  #   specify { expect(subject.path).to eq "/internal/user/#{id}" }
  #
  #   specify { expect(subject.query).to be_empty }
  #
  #   specify { expect(subject.method).to eq :get }
  #
  # end
  #
  # describe 'an #update call' do
  #
  #
  #
  # end
  #
  # describe 'a #delete call' do
  #
  #
  #
  # end
  #
  # describe 'a custom call' do
  #
  #
  #
  # end

end

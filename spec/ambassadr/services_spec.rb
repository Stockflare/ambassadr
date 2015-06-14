class Services < Ambassadr::Services.root!
end

describe Services do

  let(:root) { '/services' }

  specify { expect(Services._path).to eq root }

  specify { expect(Services::Some::Other::Service._path).to eq "#{root}/some/other/service" }

  describe 'a simple call transport receiver' do

    let(:path) { '/services/user' }

    let(:call) { :upgrade }

    specify { expect(Services::Transport).to receive(:new).with(path, call) }

    after { Services::User.send(call) }

  end

  describe 'a contextual transport receiver' do

    let(:prefix) { :admins }

    let(:id) { Random.rand(12345) }

    let(:path) { "/services/user" }

    let(:sub) { "#{prefix}/#{id}"}

    let(:call) { :activate }

    let(:args) { [] }

    subject { Services::User(prefix, id) }

    it { should respond_to(:update) }

    it { should respond_to(:delete) }

    specify { expect(Services::Transport).to receive(:new).with(path, "#{sub}/#{call}") }

    describe 'an update' do

      let(:call) { :update }

      let(:opts) { { name: Faker::Name.name } }

      let(:args) { [opts] }

      specify { expect(Services::Transport).to receive(:new).with(path, sub, opts, hash_including(method: :put)) }

    end

    describe 'a delete' do

      let(:call) { :delete }

      let(:opts) { {} }

      let(:args) { [opts] }

      specify { expect(Services::Transport).to receive(:new).with(path, sub, {}, hash_including(method: :delete)) }

    end

    after { subject.send(call, *args) }

  end

end

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

  describe 'a #create' do

    let(:path) { '/services/user' }

    let(:call) { '/' }

    let(:attrs) { { name: "David" } }

    specify { expect(Services::Transport).to receive(:new).with(path, call, attrs, hash_including(method: :post)) }

    describe 'yielded' do

      before { allow_any_instance_of(Services::Transport).to receive(:response).and_return(nil) }

      specify { expect { |b| Services::User.create(attrs, &b) }.to yield_control.once }

    end

    after { Services::User.create(attrs) }

  end

  describe 'a #get' do

    let(:path) { '/services/user' }

    let(:call) { '/' }

    let(:attrs) { { rating: Random.rand(5) } }

    specify { expect(Services::Transport).to receive(:new).with(path, call, attrs, hash_including(method: :get)) }

    describe 'yielded' do

      before { allow_any_instance_of(Services::Transport).to receive(:response).and_return(nil) }

      specify { expect { |b| Services::User.get(attrs, &b) }.to yield_control.once }

    end

    after { Services::User.get(attrs) }

  end

  describe 'a #find' do

    let(:path) { '/services/user' }

    let(:id) { Random.rand(5000) }

    specify { expect(Services::Transport).to receive(:new).with(path, id, {}, hash_including(method: :get)) }

    describe 'yielded' do

      before { allow_any_instance_of(Services::Transport).to receive(:response).and_return(nil) }

      specify { expect { |b| Services::User.find(id, &b) }.to yield_control.once }

    end

    after { Services::User.find(id) }

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

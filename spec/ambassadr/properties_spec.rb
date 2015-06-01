module Ambassadr
  describe Properties do

    let(:base) { "/#{Faker::Internet.domain_word}" }

    let(:key) { "#{Faker::Internet.domain_word}/#{Faker::Internet.domain_word}" }

    let(:path) { "#{base}/#{key}" }

    let(:value) { Faker::Internet.password }

    let(:properties) { Properties.new base }

    before { Ambassadr.etcd.set path, value: value }

    subject { properties }

    it { should respond_to(:path) }

    it { should respond_to(:get) }

    it { should respond_to(:set) }

    it { should respond_to(:properties) }

    specify { expect { subject.values }.to_not raise_error }

    describe 'when #set is called' do

      let(:a_key) { Faker::Internet.domain_word }

      let(:a_value) { Random.rand(123); sleep 1 }

      before { @resp = subject.set(a_key, a_value) }

      specify { expect(@resp).to be_truthy }

      specify { expect { subject.set(a_key, a_value + 1) }.to change { properties.get(a_key) } }

    end

    describe 'when #get is called' do

      let(:a_key) { Faker::Internet.domain_word }

      let(:a_value) { Random.rand(123).to_s }

      before { subject.set(a_key, a_value) }

      specify { expect(subject.get(a_key)).to eq a_value }

    end

    describe 'the default path' do

      subject { Properties.new.path  }

      it { should be_a String }

      it { should eq Properties::DEFAULT_PATH }

    end

    describe 'an invalid path' do

      let(:properties) { Properties.new "/#{Faker::Internet.domain_word}" }

      let(:obj) { {} }

      subject { properties }

      specify { expect { subject.properties }.to_not raise_error }

      specify { expect { subject.inject_into obj }.to_not change { obj } }

    end

    describe 'return value of #path' do

      subject { properties.path }

      it { should be_a String }

      it { should eq base }

    end

    describe 'return value of #properties' do

      subject { properties.properties }

      it { should be_a Hash }

      it { should_not be_empty }

      specify { expect(subject).to match({ key => value }) }

    end

    describe 'when #inject_into is called' do

      let(:obj) { {} }

      specify { expect { subject.inject_into obj }.to change { obj.empty? }.from(true).to(false) }

      specify { expect { |b| subject.inject_into &b }.to yield_control.at_least(1).times }

      specify { expect { |b| subject.inject_into &b }.to yield_with_args(anything(), key, value) }

      specify { expect { subject.inject_into obj { |h, k, v| h[k] = v } }.to change { obj } }

    end

    after { Ambassadr.etcd.delete base, recursive: true }

  end
end

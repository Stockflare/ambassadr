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

    it { should respond_to(:properties) }

    specify { expect { subject.values }.to_not raise_error }

    describe 'the default path' do

      subject { Properties.new.path  }

      it { should be_a String }

      it { should eq Properties.new.send(:default_path) }

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

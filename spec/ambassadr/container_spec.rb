module Ambassadr
  describe Container do

    before(:all) do
      @instance = Docker::Container.create({
        'Cmd' => ['sleep', '20'],
        'Image' => 'ambassadr/test',
        'ExposedPorts' => {
          '2345' => {},
          '4444' => {}
        }
      })
    end

    before(:all) { @instance.start({ "PublishAllPorts" => true }) }

    before(:all) { sleep 2 }

    after(:all) { @instance.kill }

    let(:ident) { @instance.id }

    let(:container) { Container.new ident }

    subject { container }

    it { should respond_to(:services) }

    it { should respond_to(:ports) }

    it { should respond_to(:hostname) }

    it { should respond_to(:host) }

    describe 'return value of #host' do

      subject { container.host }

      it { should be_a String }

      it { should_not be_empty }

      it { should eq '127.0.0.1' }

    end

    describe 'return value of #hostname' do

      subject { container.hostname }

      it { should be_a String }

      it { should_not be_empty }

    end

    describe 'return value of #services' do

      subject { container.services }

      it { should be_a Hash }

      it { should_not be_empty }

      specify { expect(subject.keys).to include "foo", "internal/user" }

      specify { expect(subject.values.sample).to match /\A[0-9]+\Z/ }

    end

    describe 'return value of #ports' do

      subject { container.ports }

      it { should be_a Hash }

      it { should_not be_empty }

      specify { expect(subject.keys).to include "2345", "4444" }

    end

  end
end

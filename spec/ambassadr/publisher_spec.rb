module Ambassadr
  describe Publisher do

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

    let(:path) { "/#{Faker::Internet.domain_word}" }

    let(:publisher) { Publisher.new container, path }

    subject { publisher }

    specify { expect { Publisher.new false, nil }.to raise_error }

    it { should respond_to(:properties) }

    it { should respond_to(:publish) }

    it { should respond_to(:publish_once) }

    specify { expect(subject.properties).to be_an_instance_of(Properties) }

    specify { expect(subject.properties.path).to eq path }

    describe 'when #publish_once is called' do

      let(:services) { subject.container.services }

      let(:num_of_services) { services.count }

      let(:keys) { services.keys.collect { |k| "#{k}/#{subject.container.hostname}" } }

      let(:values) { services.values.collect { |v| "#{subject.container.host}:#{v}" } }

      specify { expect(subject.properties).to receive(:set).with(one_of(keys), one_of(values), { ttl: Publisher::TTL }).at_least(num_of_services).times }

      after { subject.publish_once }

    end

  end
end

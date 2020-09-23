# frozen_string_literal: true

RSpec.describe PubsubClient do
  describe '.configure' do
    before do
      allow(PubsubClient::PublisherFactory).to receive(:new)
        .with(['the-topic'])
        .and_return('the-factory')
    end

    after do
      described_class.instance_variable_set(:@publisher_factory, nil)
    end

    context 'when no credentials are set' do
      before do
        described_class.instance_variable_set(:@publisher_factory, nil)
        @gac = ENV['GOOGLE_APPLICATION_CREDENTIALS']
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = nil
      end

      after do
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = @gac
      end

      it 'raises an error' do
        expect do
          described_class.configure { |_| }
        end.to raise_error(PubsubClient::CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set.')
      end
    end

    context 'when no topics are configured' do
      it 'raises an error' do
        expect do
          described_class.configure { |_| }
        end.to raise_error(PubsubClient::ConfigurationError, 'At least one topic must be configured')
      end
    end

    it 'sets the publisher factory' do
      described_class.configure do |c|
        c.topic_names << 'the-topic'
      end
      expect(described_class.instance_variable_get(:@publisher_factory))
        .to eq('the-factory')
    end

    context 'when the publisher factory has already been configured' do
      before do
        described_class.instance_variable_set(:@publisher_factory, 'some-factory')
      end

      it 'raises an error' do
        expect do
          described_class.configure { |_| }
        end.to raise_error(PubsubClient::ConfigurationError, 'PubsubClient is already configured')
      end
    end
  end

  describe '.stub!' do
    it 'returns a NullPublisherFactory' do
      expect(described_class.stub!).to be_a(PubsubClient::NullPublisherFactory)
    end

    context 'when the publisher factory has already been configured' do
      before do
        described_class.instance_variable_set(:@publisher_factory, 'some-factory')
      end

      it 'raises an error' do
        expect do
          described_class.stub!
        end.to raise_error(PubsubClient::ConfigurationError, 'PubsubClient is already configured')
      end
    end
  end

  describe '.publish' do
    let(:publisher) { instance_double(PubsubClient::Publisher, publish: nil) }

    before do
      factory = instance_double(PubsubClient::PublisherFactory, build: { 'the-topic' => publisher })
      described_class.instance_variable_set(:@publisher_factory, factory)
    end

    after do
      described_class.instance_variable_set(:@publisher_factory, nil)
    end

    it 'calls publish on the publisher' do
      described_class.publish('foo', 'the-topic') { |_| }
      expect(publisher).to have_received(:publish)
        .with('foo')
    end

    context 'when the client has not been configured or stubbed' do
      before do
        described_class.instance_variable_set(:@publisher_factory, nil)
      end

      it 'raises an error' do
        expect do
          described_class.publish('foo', 'the-topic') { |_| }
        end.to raise_error(PubsubClient::ConfigurationError, 'PubsubClient must be configured or stubbed')
      end
    end

    context 'when an invalid topic is given' do
      it 'raises an error' do
        expect do
          described_class.publish('foo', 'some-invalid-topic') { |_| }
        end.to raise_error(PubsubClient::ConfigurationError, 'Invalid topic given')
      end
    end
  end
end

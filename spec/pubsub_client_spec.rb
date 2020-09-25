# frozen_string_literal: true

RSpec.describe PubsubClient do
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
      factory = instance_double(PubsubClient::PublisherFactory, build: publisher)
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

    context 'when no credentials are set' do
      before do
        @gac = ENV['GOOGLE_APPLICATION_CREDENTIALS']
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = nil
      end

      after do
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = @gac
      end

      it 'raises an error' do
        expect do
          described_class.publish('foo', 'the-topic')
        end.to raise_error(PubsubClient::CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set')
      end
    end
  end

  describe '.subscribe' do
    let(:subscriber) { instance_double(PubsubClient::Subscriber, subscribe: nil) }

    before do
      factory = instance_double(PubsubClient::SubscriberFactory, build: subscriber)
      described_class.instance_variable_set(:@subscriber_factory, factory)
    end

    after do
      described_class.instance_variable_set(:@subscriber_factory, nil)
    end

    it 'calls subscribe on the subscriber' do
      described_class.subscribe('foo')
      expect(subscriber).to have_received(:subscribe)
        .with('foo')
    end
  end
end

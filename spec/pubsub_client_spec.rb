# frozen_string_literal: true

RSpec.describe PubsubClient do

  before(:all) do
    @client = PubsubClient.new
  end

  describe '.stub!' do
    before(:all) do
      @client.stub!
    end

    after(:all) do
      @client.instance_variable_set(:@stubbed, nil)
    end

    context 'config' do
      it 'default sets publish_timeout to nil' do
        expect(@client.config.publish_timeout).to be_nil
      end

      context 'when config is set' do
        let(:publish_timeout) { 5 }

        before do
          @original_publish_timeout = @client.config.publish_timeout
          @client.configure do |c|
            c.publish_timeout = publish_timeout
          end
        end

        after do
          @client.configure do |c|
            c.publish_timeout = @original_publish_timeout
          end
        end

        it 'sets the configured value' do
          expect(@client.config.publish_timeout).to eq(publish_timeout)
        end
      end
    end

    context 'it sets the null factories' do
      it 'sets a NullPublisherFactory as the publisher factory' do
        expect(@client.instance_variable_get(:@publisher_factory)).to be_a(PubsubClient::NullPublisherFactory)
      end

      it 'sets a NullSubscriberFactory as the subscriber factory' do
        expect(@client.instance_variable_get(:@subscriber_factory)).to be_a(PubsubClient::NullSubscriberFactory)
      end
    end

    context 'when the publisher factory has already been configured' do
      before do
        @client.instance_variable_set(:@publisher_factory, 'some-factory')
      end

      it 'raises an error' do
        expect do
          @client.stub!
        end.to raise_error(PubsubClient::ConfigurationError, 'PubsubClient is already configured')
      end
    end

    context 'when the subscriber factory has already been configured' do
      before do
        @client.instance_variable_set(:@subscriber_factory, 'some-factory')
      end

      it 'raises an error' do
        expect do
          @client.stub!
        end.to raise_error(PubsubClient::ConfigurationError, 'PubsubClient is already configured')
      end
    end

    it 'does not require credentials for publishing' do
      expect do
        @client.publish('foo', 'the-topic') {}
      end.to_not raise_error
    end

    it 'does not require credentials for getting a handle to a subscriber' do
      expect do
        @client.subscriber('foo')
      end.to_not raise_error
    end
  end

  describe '.publish' do
    let(:publisher) { instance_double(PubsubClient::Publisher, publish: nil) }

    before do
      factory = instance_double(PubsubClient::PublisherFactory, build: publisher)
      @client.instance_variable_set(:@publisher_factory, factory)
    end

    after do
      @client.instance_variable_set(:@publisher_factory, nil)
    end

    it 'calls publish on the publisher' do
      @client.publish('foo', 'the-topic')
      expect(publisher).to have_received(:publish)
        .with('foo', {})
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
          @client.publish('foo', 'the-topic')
        end.to raise_error(PubsubClient::CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set')
      end
    end
  end

  describe '.subscriber' do
    let(:subscriber) { instance_double(PubsubClient::Subscriber, listener: nil) }

    before do
      factory = instance_double(PubsubClient::SubscriberFactory, build: subscriber)
      @client.instance_variable_set(:@subscriber_factory, factory)
    end

    after do
      @client.instance_variable_set(:@subscriber_factory, nil)
    end

    it 'it returns the subscriber' do
      @client.subscriber('foo')
      expect(@client.subscriber('foo')).to eq(subscriber)
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
          @client.subscriber('foo')
        end.to raise_error(PubsubClient::CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set')
      end
    end
  end
end

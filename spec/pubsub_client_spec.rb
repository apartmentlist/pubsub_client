# frozen_string_literal: true

RSpec.describe PubsubClient do
  describe '.configure' do
    before do
      described_class.stub!
      allow(PubsubClient::PublisherFactory).to receive(:new)
        .with('the-topic', true)
        .and_return('the-factory')
    end

    after do
      described_class.instance_variable_set(:@publisher_factory, nil)
    end

    context 'when the topic name is not configured' do
      it 'raises an error' do
        expect do
          described_class.configure do |c|
            c.topic_name = nil
          end
        end.to raise_error(PubsubClient::ConfigurationError, 'The topic_name must be configured.')
      end
    end

    it 'sets the publisher factory' do
      described_class.configure do |c|
        c.topic_name = 'the-topic'
      end
      expect(described_class.instance_variable_get(:@publisher_factory))
        .to eq('the-factory')
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
          described_class.publish('foo')
        end.to raise_error(PubsubClient::CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set.')
      end
    end

    it 'calls publish on the publisher' do
      described_class.publish('foo') { |_| }
      expect(publisher).to have_received(:publish)
        .with('foo')
    end
  end
end

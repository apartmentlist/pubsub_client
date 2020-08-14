# frozen_string_literal: true

RSpec.describe PubsubClient do
  let(:publisher) { instance_double(PubsubClient::Publisher, publish: nil) }

  before do
    allow(PubsubClient::PublisherFactory)
      .to receive(:build)
      .and_return(publisher)
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

  context 'when no topic is configured' do
    before do
      @topic = described_class.config.topic_name
      described_class.config.topic_name = nil
    end

    after do
      described_class.config.topic_name = @topic
    end

    it 'raises an error' do
      expect do
        described_class.publish('foo')
      end.to raise_error(PubsubClient::ConfigurationError, 'The topic_name must be configured.')
    end
  end

  it 'calls publish on the publisher' do
    described_class.publish('foo') { |_| }
    expect(publisher).to have_received(:publish)
  end
end

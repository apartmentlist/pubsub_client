RSpec.describe PubsubClient do
  let(:pubsub) { instance_double(Google::Cloud::PubSub::Project) }
  let(:topic) { instance_double(Google::Cloud::PubSub::Topic) }

  before do
    allow(Google::Cloud::PubSub)
      .to receive(:new)
      .and_return(pubsub)
    allow(pubsub)
      .to receive(:topic)
      .with('the-topic') # the topic name is configured in spec_helper.rb
      .and_return(topic)
    allow(topic)
      .to receive(:publish_async)
      .and_yield('the-result')
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

  it 'publishes the message asynchronously' do
    described_class.publish('foo') { |_| }
    expect(topic).to have_received(:publish_async)
      .with('foo')
  end

  it 'yields the result to a block' do
    yielded_result = nil
    described_class.publish('foo') do |result|
      yielded_result = result
    end
    expect(yielded_result).to eq('the-result')
  end
end

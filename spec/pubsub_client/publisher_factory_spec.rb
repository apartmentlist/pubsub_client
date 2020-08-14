# frozen_string_literal: true

module PubsubClient
  RSpec.describe PublisherFactory do
    let(:pubsub) { instance_double(Google::Cloud::PubSub::Project) }
    let(:topic) { instance_double(Google::Cloud::PubSub::Topic) }
    let(:publisher) { instance_double(Publisher) }

    before do
      allow(Google::Cloud::PubSub)
        .to receive(:new)
        .and_return(pubsub)
      allow(pubsub)
        .to receive(:topic)
        .with('the-topic') # the topic name is configured in spec_helper.rb
        .and_return(topic)
      allow(Publisher)
        .to receive(:new)
        .and_return(publisher)
    end

    it 'builds the publisher' do
      described_class.build('the-topic')
      expect(Publisher).to have_received(:new)
        .with(topic)
    end

    it 'returns the publisher' do
      expect(described_class.build('the-topic')).to eq(publisher)
    end
  end
end

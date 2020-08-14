# frozen_string_literal: true

module PubsubClient
  RSpec.describe PublisherFactory do
    subject(:factory) { described_class.new('the-topic') }

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

    after do
      factory.instance_variable_set(:@publisher, nil)
      factory.instance_variable_set(:@publisher_pid, nil)
    end

    context 'when the process is forked' do
      before do
        allow(factory).to receive(:current_pid)
          .and_return(1, 2)
      end

      it 'creates a new publisher' do
        2.times do
          factory.build
        end

        expect(pubsub).to have_received(:topic).twice
      end
    end

    it 'memoizes the publisher' do
      2.times do
        factory.build
      end

      expect(pubsub).to have_received(:topic).once
    end

    it 'builds the publisher' do
      factory.build
      expect(Publisher).to have_received(:new)
        .with(topic)
    end

    it 'returns the publisher' do
      expect(factory.build).to eq(publisher)
    end
  end
end

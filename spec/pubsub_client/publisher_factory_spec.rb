# frozen_string_literal: true

module PubsubClient
  RSpec.describe PublisherFactory do
    subject(:factory) { described_class.new }

    let(:pubsub) { instance_double(Google::Cloud::PubSub::Project) }
    let(:topic) { instance_double(Google::Cloud::PubSub::Topic) }
    let(:publisher) do
      # The factory ensures the #flush method of publisher is called on exit, so
      # we cannot use doubles. Thus, created a lightweight object that will respond
      # to #flush
      Struct.new(:flush).new
    end

    before do
      allow(Google::Cloud::PubSub)
        .to receive(:new)
        .and_return(pubsub)
      allow(pubsub)
        .to receive(:topic)
        .with('the-topic')
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
          factory.build('the-topic')
        end

        expect(pubsub).to have_received(:topic).twice
      end
    end

    it 'builds the publisher' do
      factory.build('the-topic')
      expect(Publisher).to have_received(:new)
        .with(topic)
    end

    it 'returns the publisher' do
      expect(factory.build('the-topic')).to eq(publisher)
    end

    context 'multiple topics' do
      let(:topic1) { instance_double(Google::Cloud::PubSub::Topic, name: '/projects/project-identifier/topics/topic-1') }
      let(:topic2) { instance_double(Google::Cloud::PubSub::Topic, name: '/projects/project-identifier/topics/topic-2') }

      # We need a way to distinguish between these objects and setting an `id`
      # attribute will allow us to do that.
      let(:publisher1) { Struct.new(:flush, :id).new }
      let(:publisher2) { Struct.new(:flush, :id).new }

      before do
        publisher1.id = 1
        publisher2.id = 2

        allow(pubsub)
          .to receive(:topic)
          .with('topic-1')
          .and_return(topic1)
        allow(pubsub)
          .to receive(:topic)
          .with('topic-2')
          .and_return(topic2)
        allow(Publisher)
          .to receive(:new)
          .with(topic1)
          .and_return(publisher1)
        allow(Publisher)
          .to receive(:new)
          .with(topic2)
          .and_return(publisher2)
      end

      it 'builds different publishers for different topics' do
        expect(factory.build('topic-1')).to eq(publisher1)
        expect(factory.build('topic-2')).to eq(publisher2)
      end

      it 'memoizes all publishers' do
        2.times do
          factory.build('topic-1')
          factory.build('topic-2')
        end

        expect(pubsub).to have_received(:topic)
          .with('topic-1')
          .once
        expect(pubsub).to have_received(:topic)
          .with('topic-2')
          .once
      end
    end
  end
end

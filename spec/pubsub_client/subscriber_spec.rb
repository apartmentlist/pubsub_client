# frozen_string_literal: true

module PubsubClient
  RSpec.describe Subscriber do
    subject(:subscriber) { described_class.new(subscription) }

    let(:subscription) { instance_double(Google::Cloud::PubSub::Subscription) }
    let(:listener) { instance_double(Google::Cloud::PubSub::Subscriber) }

    before do
      # This must be stubbed out so that the process that runs the specs doesn't
      # actually sleep.
      allow(subscriber).to receive(:sleep)
      allow(subscription).to receive(:listen)
        .with({ threads: { callback: 1 } })
        .and_return(listener)
      allow(listener).to receive(:start)
    end

    it 'starts the subscriber' do
      subject.subscribe(1, true)
      expect(listener).to have_received(:start)
    end

    context 'when there is a SignalException' do
      before do
        allow(subscriber).to receive(:sleep)
          .and_raise(SignalException.new('HUP'))

        allow(listener).to receive(:stop)
          .and_return(listener)
        allow(listener).to receive(:wait!)
      end

      it 'stops the subscriber' do
        subject.subscribe(1, true)
        expect(listener).to have_received(:stop)
        expect(listener).to have_received(:wait!)
      end
    end

    context 'listener block' do
      let(:pubsub_message) {
        instance_double(Google::Cloud::PubSub::ReceivedMessage, data: 'the-message', acknowledge!: nil)
      }

      before do
        allow(subscription).to receive(:listen)
          .with({ threads: { callback: 1 } })
          .and_yield(pubsub_message)
          .and_return(listener)
      end

      it 'yields the message' do
        yielded_message = nil
        subject.subscribe(1, true) do |message|
          yielded_message = message
        end
        expect(yielded_message).to eq('the-message')
      end

      it 'acks the message' do
        subject.subscribe(1, true) { |_| }
        expect(pubsub_message).to have_received(:acknowledge!)
      end

      context 'when auto ack is not desired' do
        it 'does not ack the message' do
          subject.subscribe(1, false) { |_| }
          expect(pubsub_message).to_not have_received(:acknowledge!)
        end
      end
    end
  end
end

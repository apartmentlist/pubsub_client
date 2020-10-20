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

        allow(listener).to receive(:stop) { listener }
        allow(listener).to receive(:wait!)
      end

      it 'stops the subscriber' do
        subject.subscribe(1, true)
        expect(listener).to have_received(:stop)
        expect(listener).to have_received(:wait!)
      end
    end
  end
end

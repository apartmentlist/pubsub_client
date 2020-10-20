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
      allow(subscription)
        .to receive(:listen)
        .and_yield('the-message')
      allow(subscription).to receive(:listen)
        .and_return(listener)
      allow(listener).to receive(:start)
    end

    it 'starts the subscriber' do
      subject.subscribe { |_| }
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
        subject.subscribe
        expect(listener).to have_received(:stop)
        expect(listener).to have_received(:wait!)
      end
    end

    xit 'yields the result to a block' do
      yielded_result = nil
      subject.subscribe do |result|
        yielded_result = result
      end
      listener.start
      expect(yielded_result).to eq('the-result')
    end
  end
end

# frozen_string_literal: true

module PubsubClient
  RSpec.describe Subscriber do
    subject(:subscriber) { described_class.new(subscription) }

    let(:subscription) { instance_double(Google::Cloud::PubSub::Subscription) }
    let(:google_subscriber) { instance_double(Google::Cloud::PubSub::Subscriber) }

    before do
      # This must be stubbed out so that the process that runs the specs doesn't
      # actually sleep.
      allow(subscriber).to receive(:sleep)
      allow(subscription)
        .to receive(:listen)
        .and_yield('the-message')
      allow(subscription).to receive(:listen)
        .and_return(google_subscriber)
      allow(google_subscriber).to receive(:start)
    end

    it 'starts the subscriber' do
      subject.subscribe { |_| }
      expect(google_subscriber).to have_received(:start)
    end

    context 'when there is a SignalException' do
      before do
        allow(subscriber).to receive(:sleep)
          .and_raise(SignalException.new('HUP'))

        allow(google_subscriber).to receive(:stop) { google_subscriber }
        allow(google_subscriber).to receive(:wait!)
      end

      it 'stops the subscriber' do
        subject.subscribe
        expect(google_subscriber).to have_received(:stop)
        expect(google_subscriber).to have_received(:wait!)
      end
    end

    xit 'yields the result to a block' do
      yielded_result = nil
      subject.subscribe do |result|
        yielded_result = result
      end
      google_subscriber.start
      expect(yielded_result).to eq('the-result')
    end
  end
end

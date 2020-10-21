# frozen_string_literal: true

module PubsubClient
  RSpec.describe Subscriber do
    subject(:subscriber) { described_class.new(subscription) }

    let(:subscription) { instance_double(Google::Cloud::PubSub::Subscription) }
    let(:listener) { instance_double(Google::Cloud::PubSub::Subscriber) }
    let(:pubsub_message) {
      instance_double(Google::Cloud::PubSub::ReceivedMessage, data: 'the-message', acknowledge!: nil)
    }

    before do
      # This must be stubbed out so that the process that runs the specs doesn't
      # actually sleep.
      allow(subscriber).to receive(:sleep)
      allow(subscription).to receive(:listen)
        .with({ threads: { callback: 1 } })
        .and_yield(pubsub_message)
        .and_return(listener)
      allow(listener).to receive(:start)
    end

    describe '.subscribe' do
      it 'starts the listener' do
        subject.listener(1, true) { |_,_| }
        subject.subscribe
        expect(listener).to have_received(:start)
      end

      it 'acks the message' do
        subject.listener(1, true) { |_,_| }
        subject.subscribe
        expect(pubsub_message).to have_received(:acknowledge!)
      end

      context 'when auto ack is not desired' do
        it 'does not ack the message' do
          subject.listener(1, false) { |_,_| }
          subject.subscribe
          expect(pubsub_message).to_not have_received(:acknowledge!)
        end
      end

      context 'when there is no listener configured' do
        it 'raises a configuration error' do
          expect do
            subject.subscribe { |_| }
          end.to raise_error(PubsubClient::ConfigurationError, 'A listener must be configured')
        end
      end

      context 'when there is a SignalException' do
        before do
          allow(subject).to receive(:sleep)
            .and_raise(SignalException.new('HUP'))

          allow(listener).to receive(:stop)
            .and_return(listener)
          allow(listener).to receive(:wait!)
        end

        it 'stops the subscriber' do
          subject.listener(1, true) { |_,_| }
          subject.subscribe
          expect(listener).to have_received(:stop)
          expect(listener).to have_received(:wait!)
        end
      end
    end

    describe '.on_error' do
      before do
        subject.instance_variable_set(:@listener, listener)
        allow(listener).to receive(:on_error)
          .and_yield(StandardError.new('Boom!'))
      end

      it 'yields the exception' do
        yielded_ex = nil
        subject.on_error do |ex|
          yielded_ex = ex
        end
        expect(yielded_ex.message).to eq('Boom!')
      end

      context 'when there is no listener configured' do
        before do
          subject.instance_variable_set(:@listener, nil)
        end

        it 'raises a configuration error' do
          expect do
            subject.on_error { |_| }
          end.to raise_error(PubsubClient::ConfigurationError, 'A listener must be configured')
        end
      end
    end
  end
end

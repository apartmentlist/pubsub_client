# frozen_string_literal: true

class PubsubClient
  RSpec.describe SubscriberFactory do
    subject(:factory) { described_class.new }

    let(:pubsub) { instance_double(Google::Cloud::PubSub::Project) }
    let(:subscription) { instance_double(Google::Cloud::PubSub::Subscription) }
    let(:subscriber) { instance_double(Subscriber) }

    before do
      allow(Google::Cloud::PubSub)
        .to receive(:new)
        .and_return(pubsub)
      allow(pubsub)
        .to receive(:subscription)
        .with('the-subscription')
        .and_return(subscription)
      allow(Subscriber)
        .to receive(:new)
        .and_return(subscriber)
    end

    it 'builds the subscriber' do
      factory.build('the-subscription')
      expect(Subscriber).to have_received(:new)
        .with(subscription)
    end

    it 'returns the subscriber' do
      expect(factory.build('the-subscription')).to eq(subscriber)
    end

    context 'when the subscription does not exist' do
      before do
        allow(pubsub)
          .to receive(:subscription)
          .with('invalid-subscription')
          .and_return(nil)
      end

      it 'raises an error' do
        expect do
          factory.build('invalid-subscription')
        end.to raise_error(InvalidSubscriptionError, 'The subscription invalid-subscription does not exist')
      end
    end

    context 'when the subscription has already been subscribed to' do
      before do
        factory.build('the-subscription')
      end

      it 'raises an error' do
        expect do
          factory.build('the-subscription')
        end.to raise_error(ConfigurationError, 'PubsubClient already subscribed to the-subscription')
      end
    end
  end
end

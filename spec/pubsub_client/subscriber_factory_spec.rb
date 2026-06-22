# frozen_string_literal: true

class PubsubClient
  RSpec.describe SubscriberFactory do
    subject(:factory) { described_class.new }

    let(:pubsub) { instance_double(Google::Cloud::PubSub::Project) }
    let(:subscription_admin) { double('subscription_admin') }
    let(:gcloud_subscriber) { instance_double(Google::Cloud::PubSub::Subscriber) }
    let(:subscriber) { instance_double(Subscriber) }

    before do
      allow(Google::Cloud::PubSub)
        .to receive(:new)
        .and_return(pubsub)
      allow(pubsub).to receive(:subscription_admin).and_return(subscription_admin)
      allow(pubsub).to receive(:subscription_path) { |name| "projects/test/subscriptions/#{name}" }
      allow(subscription_admin).to receive(:get_subscription)
      allow(pubsub)
        .to receive(:subscriber)
        .with('the-subscription')
        .and_return(gcloud_subscriber)
      allow(Subscriber)
        .to receive(:new)
        .and_return(subscriber)
    end

    it 'builds the subscriber' do
      factory.build('the-subscription')
      expect(Subscriber).to have_received(:new)
        .with(gcloud_subscriber)
    end

    it 'returns the subscriber' do
      expect(factory.build('the-subscription')).to eq(subscriber)
    end

    context 'when the subscription does not exist' do
      before do
        allow(subscription_admin)
          .to receive(:get_subscription)
          .with(subscription: 'projects/test/subscriptions/invalid-subscription')
          .and_raise(Google::Cloud::NotFoundError.new('not found'))
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

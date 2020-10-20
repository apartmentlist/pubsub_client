# frozen_string_literal: true

require_relative 'subscriber'

module PubsubClient
  class SubscriberFactory
    def initialize
      @subscribers = {}
    end

    def build(subscription_name)
      if @subscribers.key?(subscription_name)
        raise ConfigurationError, "PubsubClient already subscribed to #{subscription_name}"
      end

      @subscribers[subscription_name] = build_subscriber(subscription_name)
    end

    private

    def build_subscriber(subscription_name)
      pubsub = Google::Cloud::PubSub.new
      subscription = pubsub.subscription(subscription_name)
      raise InvalidSubscriptionError, "The subscription #{subscription_name} does not exist" unless subscription
      Subscriber.new(subscription)
    end
  end
end

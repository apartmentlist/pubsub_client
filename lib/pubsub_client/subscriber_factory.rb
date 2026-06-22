# frozen_string_literal: true

require_relative 'subscriber'

class PubsubClient
  class SubscriberFactory
    def initialize
      @subscribers = {}
    end

    # @param subscription_name [String]
    # @retrun [Subscriber]
    def build(subscription_name)
      if @subscribers.key?(subscription_name)
        raise ConfigurationError, "PubsubClient already subscribed to #{subscription_name}"
      end

      @subscribers[subscription_name] = build_subscriber(subscription_name)
    end

    private

    def build_subscriber(subscription_name)
      pubsub = Google::Cloud::PubSub.new
      ensure_subscription_exists!(pubsub, subscription_name)
      Subscriber.new(pubsub.subscriber(subscription_name))
    end

    def ensure_subscription_exists!(pubsub, subscription_name)
      pubsub.subscription_admin.get_subscription(
        subscription: pubsub.subscription_path(subscription_name)
      )
    rescue Google::Cloud::NotFoundError
      raise InvalidSubscriptionError, "The subscription #{subscription_name} does not exist"
    end
  end
end

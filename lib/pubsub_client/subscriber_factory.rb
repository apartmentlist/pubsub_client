# frozen_string_literal: true

module PubsubClient
  class SubscriberFactory
    def initialize
      @subscribers = {}
    end

    def build(subscription_name)
      if subscribers.key?(subscription_name)
        raise ConfigurationError, "PubsubClient already subscribed to #{subscription_name}"
      end
    end
  end
end

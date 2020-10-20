# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Subscriber
    # @param subscription [Google::Cloud::PubSub::Subscription]
    def initialize(subscription)
      @subscription = subscription
    end

    # flag for auto-ack
    def subscribe(&block)
      listener = @subscription.listen do |received_message|
        yield received_message
      end

      begin
        listener.start
        sleep
      rescue SignalException
        listener.stop.wait!
      end
    end
  end
end

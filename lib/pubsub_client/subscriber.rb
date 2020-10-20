# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Subscriber
    DEFAULT_CONCURRENCY = 8

    # @param subscription [Google::Cloud::PubSub::Subscription]
    def initialize(subscription)
      @subscription = subscription
    end

    # flag for auto-ack
    # @param concurrency [Integer]
    def subscribe(concurrency, &block)
      listener = @subscription.listen(threads: { callback: concurrency }) do |received_message|
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

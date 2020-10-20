# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Subscriber
    DEFAULT_CONCURRENCY = 8

    # @param subscription [Google::Cloud::PubSub::Subscription]
    def initialize(subscription)
      @subscription = subscription
    end

    # @param concurrency [Integer]
    # @param auto_ack [Boolean]
    def subscribe(concurrency, auto_ack, &block)
      listener = @subscription.listen(threads: { callback: concurrency }) do |received_message|
        yield received_message.data
        received_message.acknowledge! if auto_ack
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

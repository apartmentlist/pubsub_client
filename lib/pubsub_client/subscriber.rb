# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Subscriber
    DEFAULT_CONCURRENCY = 8

    # @param subscription [Google::Cloud::PubSub::Subscription]
    def initialize(subscription)
      @subscription = subscription
    end

    # @param concurrency [Integer] - The number of threads to run the subscriber with.
    # @param auto_ack [Boolean] - Flag to acknowledge the Pub/Sub message. A message must be
    #                             acked to remove it from the topic. Default is `true`.
    #
    # @return [Google::Cloud::PubSub::Subscriber]
    def listener(concurrency = DEFAULT_CONCURRENCY, auto_ack = true, &block)
      @listener ||= begin
        @subscription.listen(threads: { callback: concurrency }) do |received_message|
          yield received_message.data, received_message
          received_message.acknowledge! if auto_ack
        end
      end
    end

    def subscribe
      raise ConfigurationError, 'A listener must be configured' unless @listener

      begin
        @listener.start

        sleep
      rescue SignalException
        @listener.stop.wait!
      end
    end

    def on_error(&block)
      raise ConfigurationError, 'A listener must be configured' unless @listener

      @listener.on_error do |exception|
        yield exception
      end
    end
  end
end

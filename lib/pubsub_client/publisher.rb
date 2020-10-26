# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Publisher
    # @param topic [Google::Cloud::PubSub::Topic]
    def initialize(topic)
      @topic = topic
    end

    def publish(message, attributes = {}, &block)
      topic.publish_async(message, attributes, &block)
    end

    def flush
      return unless topic.async_publisher
      topic.async_publisher.stop.wait!
    end

    private

    attr_reader :topic
  end
end

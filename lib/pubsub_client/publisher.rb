# frozen_string_literal: true

require 'google/cloud/pubsub'

class PubsubClient
  class Publisher
    # @param topic [Google::Cloud::PubSub::Topic]
    def initialize(topic)
      @topic = topic
    end

    def publish(message, attributes = {}, &block)
      topic.publish_async(message, attributes, &block)
    end

    # https://googleapis.dev/ruby/google-cloud-pubsub/latest/Google/Cloud/PubSub/Topic.html#publish-instance_method
    #
    # @return [Google::Cloud::PubSub::Message | Array<Google::Cloud::PubSub::Message>]
    #         Returns the published message when called without a block, or an array of messages
    #         when called with a block.
    def synchronous_publish(message, attributes = {}, &block)
      topic.publish(message, attributes, &block)
    end

    def flush
      return unless topic.async_publisher
      topic.async_publisher.stop.wait!
    end

    private

    attr_reader :topic
  end
end

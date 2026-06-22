# frozen_string_literal: true

require 'google/cloud/pubsub'

class PubsubClient
  class Publisher
    # @param publisher [Google::Cloud::PubSub::Publisher]
    def initialize(publisher)
      @publisher = publisher
    end

    def publish(message, attributes = {}, &block)
      publisher.publish_async(message, attributes, &block)
    end

    # https://cloud.google.com/ruby/docs/reference/google-cloud-pubsub/latest/Google-Cloud-PubSub-Publisher#Google__Cloud__PubSub__Publisher_publish_instance_
    #
    # @return [Google::Cloud::PubSub::Message | Array<Google::Cloud::PubSub::Message>]
    #         Returns the published message when called without a block, or an array of messages
    #         when called with a block.
    def synchronous_publish(message, attributes = {}, &block)
      publisher.publish(message, attributes, &block)
    end

    def flush
      return unless publisher.async_publisher
      publisher.async_publisher.stop.wait!
    end

    private

    attr_reader :publisher
  end
end

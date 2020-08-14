# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Publisher
    def initialize(topic)
      @topic = topic
    end

    def publish(message, &block)
      topic.publish_async(message, &block)
    end

    private

    attr_reader :topic
  end
end

# frozen_string_literal: true

require_relative 'publisher'

module PubsubClient
  module PublisherFactory
    class << self
      def build(topic_name)
        pubsub = Google::Cloud::PubSub.new
        topic = pubsub.topic(topic_name)
        Publisher.new(topic)
      end
    end
  end
end

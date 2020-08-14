# frozen_string_literal: true

require_relative 'publisher'

module PubsubClient
  class PublisherFactory
    def initialize(topic_name)
      @topic_name = topic_name
    end

    def build
      return @publisher if @publisher_pid == current_pid
      pubsub = Google::Cloud::PubSub.new
      topic = pubsub.topic(topic_name)
      @publisher_pid = Process.pid
      @publisher = Publisher.new(topic)
    end

    private

    attr_reader :topic_name

    # Used for testing to simulate when a
    # process is forked. In those cases,
    # this helps us test that the `.build`
    # method creates different publishers.
    def current_pid
      Process.pid
    end
  end
end

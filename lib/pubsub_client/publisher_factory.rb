# frozen_string_literal: true

require_relative 'publisher'
require_relative 'null_publisher'

module PubsubClient
  # Build and memoize the Publisher, accounting for GRPC's requirements around forking.
  class PublisherFactory
    def initialize(topic_name, stubbed)
      @topic_name = topic_name
      @stubbed = stubbed
      @mutex = Mutex.new
    end

    def build
      # GRPC fails when attempting to use a connection created in a process that gets
      # forked with the message
      #
      #  "grpc cannot be used before and after forking"
      #
      # Also creating a new publsher incurs significant overhead as it connects to
      # PubSub.
      #
      # To prevent incurring overhead, memoize the publisher per process.
      return @publisher if @publisher_pid == current_pid

      # We are in a multi-threaded world and need to be careful not to build the publisher
      # in multiple threads. Lock the mutex so that only one thread can enter this block
      # at a time.
      mutex.synchronize do
        # It's possible two threads made it to this point, but since we have a lock we
        # know that one will have built the publisher before the second is able to enter.
        # If we detect that case, then bail out so as to not rebuild the publisher.
        unless @publisher_pid == current_pid
          @publisher = build_publisher
          @publisher_pid = Process.pid
        end
      end

      @publisher
    end

    private

    attr_reader :mutex, :stubbed, :topic_name

    # Used for testing to simulate when a process is forked. In those cases,
    # this helps us test that the `.build` method creates different publishers.
    def current_pid
      Process.pid
    end

    def build_publisher
      return NullPublisher.new if stubbed

      pubsub = Google::Cloud::PubSub.new
      topic = pubsub.topic(topic_name)
      publisher = Publisher.new(topic)

      at_exit { publisher.flush }

      publisher
    end
  end
end

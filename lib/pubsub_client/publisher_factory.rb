# frozen_string_literal: true

require_relative 'publisher'

class PubsubClient
  # Build and memoize the Publisher, accounting for GRPC's requirements around forking.
  class PublisherFactory
    def initialize
      @mutex = Mutex.new
      @publishers = {}
    end

    # @param topic_name [String]
    # @return [Publisher]
    def build(topic_name, timeout = nil)
      # GRPC fails when attempting to use a connection created in a process that gets
      # forked with the message
      #
      #  "grpc cannot be used before and after forking"
      #
      # Also creating a new publsher incurs significant overhead as it connects to
      # PubSub.
      #
      # To prevent incurring overhead, memoize the publisher per process.
      return publishers[topic_name].publisher if publishers[topic_name]&.pid == current_pid

      # We are in a multi-threaded world and need to be careful not to build the publisher
      # in multiple threads. Lock the mutex so that only one thread can enter this block
      # at a time.
      @mutex.synchronize do
        # It's possible two threads made it to this point, but since we have a lock we
        # know that one will have built the publisher before the second is able to enter.
        # If we detect that case, then bail out so as to not rebuild the publisher.
        unless publishers[topic_name]&.pid == current_pid
          publisher = timeout.nil? ? build_publisher(topic_name) : build_synchronous(topic_name, timeout)
          publishers[topic_name] = Memo.new(publisher, Process.pid)
        end
      end

      publishers[topic_name].publisher
    end

    private

    attr_accessor :publishers

    Memo = Struct.new(:publisher, :pid)

    # Used for testing to simulate when a process is forked. In those cases,
    # this helps us test that the `.build` method creates different publishers.
    def current_pid
      Process.pid
    end

    def build_publisher(topic_name)
      pubsub = Google::Cloud::PubSub.new
      topic = pubsub.topic(topic_name)
      raise InvalidTopicError, "The topic #{topic_name} does not exist" unless topic
      publisher = Publisher.new(topic)

      at_exit { publisher.flush }

      publisher
    end

    def build_synchronous(topic_name, publish_timeout)
      pubsub = Google::Cloud::PubSub.new(timeout: publish_timeout)
      topic = pubsub.topic(topic_name)
      raise InvalidTopicError, "The topic #{topic_name} does not exist" unless topic

      Publisher.new(topic)
    end
  end
end

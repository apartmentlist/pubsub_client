# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Subscriber
    def initialize(topic)
      @topic = topic
    end


    def subscribe
    end

    private

    attr_reader :topic
  end
end

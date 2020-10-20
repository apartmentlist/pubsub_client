# frozen_string_literal: true

require 'google/cloud/pubsub'

module PubsubClient
  class Subscriber
    def initialize(subscription)
      @subscription = subscription
    end

    # flag for auto-ack
    def subscribe(&block)
      puts 'Inside Subscriber#subscribe'
      subscriber = @subscription.listen do |received_message|
        yield received_message
      end

      begin
        puts 'Starting subscriber...'
        subscriber.start
        sleep
      rescue SignalException
        subscriber.stop.wait!
        puts 'Subscriber STOPPED'
      end
    end
  end
end

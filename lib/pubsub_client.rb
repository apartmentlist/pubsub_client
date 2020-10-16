require 'pubsub_client/version'
require 'pubsub_client/null_publisher_factory'
require 'pubsub_client/publisher_factory'
require 'pubsub_client/subscriber_factory'

module PubsubClient
  Error = Class.new(StandardError)
  ConfigurationError = Class.new(Error)
  CredentialsError = Class.new(Error)
  InvalidTopicError = Class.new(Error)

  class << self
    def stub!
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory
      @publisher_factory = NullPublisherFactory.new
    end

    def publish(message, topic, &block)
      ensure_credentials!

      @publisher_factory ||= PublisherFactory.new
      @publisher_factory.build(topic).publish(message, &block)
    end

    def subscribe(subscription)
      ensure_credentials!

      @subscriber_factory ||= SubscriberFactory.new
      subscription = @subscriber_factory.build(subscription)
      subscriber = subscription.listen do |received_message|
        yield received_message
      end

      begin
        puts 'Starting subscriber...'
        subscriber.start
        sleep
      rescue SignalException
        subscriber.stop.wait!
      end
    end

    private

    def ensure_credentials!
      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set'
      end
    end
  end
end

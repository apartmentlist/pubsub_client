require 'pubsub_client/version'
require 'pubsub_client/null_publisher_factory'
require 'pubsub_client/null_subscriber_factory'
require 'pubsub_client/publisher_factory'
require 'pubsub_client/subscriber_factory'

module PubsubClient
  Error = Class.new(StandardError)
  ConfigurationError = Class.new(Error)
  CredentialsError = Class.new(Error)
  InvalidTopicError = Class.new(Error)
  InvalidSubscriptionError = Class.new(Error)

  class << self
    def stub!
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory || @subscriber_factory
      @publisher_factory = NullPublisherFactory.new
      @subscriber_factory = NullSubscriberFactory.new
      @stubbed = true
    end

    # @param message [String] The message to publish.
    # @param topic [String] The name of the topic to publish to.
    def publish(message, topic, attributes = {}, &block)
      ensure_credentials!

      @publisher_factory ||= PublisherFactory.new
      @publisher_factory.build(topic).publish(message, attributes, &block)
    end

    # @param subscription [String] - The name of the topic to subscribe to.
    def subscriber(subscription)
      ensure_credentials!

      @subscriber_factory ||= SubscriberFactory.new
      @subscriber_factory.build(subscription)
    end

    private

    def ensure_credentials!
      return if defined?(@stubbed) && @stubbed
      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set'
      end
    end
  end
end

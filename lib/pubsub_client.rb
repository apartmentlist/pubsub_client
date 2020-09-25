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
      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set'
      end

      @publisher_factory ||= PublisherFactory.new
      @publisher_factory.build(topic).publish(message, &block)
    end

    def subscribe(subscription)
      @subscriber_factory ||= SubscriberFactory.new
      @subscriber_factory.build(subscription).subscribe
    end
  end
end

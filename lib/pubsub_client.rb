require 'pubsub_client/version'
require 'pubsub_client/null_publisher_factory'
require 'pubsub_client/publisher_factory'

module PubsubClient
  Error = Class.new(StandardError)
  ConfigurationError = Class.new(Error)
  InvalidTopicError = Class.new(Error)

  class << self
    def stub!
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory
      @publisher_factory = NullPublisherFactory.new
    end

    def publish(message, topic, &block)
      @publisher_factory ||= PublisherFactory.new
      @publisher_factory.build(topic).publish(message, &block)
    end
  end
end

require 'pubsub_client/version'
require 'pubsub_client/null_publisher_factory'
require 'pubsub_client/publisher_factory'

module PubsubClient
  Error = Class.new(StandardError)
  CredentialsError = Class.new(Error)
  ConfigurationError = Class.new(Error)

  Config = Struct.new(:topic_names) do
    def initialize(topic_names: [])
      super(topic_names)
    end
  end

  class << self
    def configure(&block)
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory

      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set.'
      end

      config = Config.new
      yield config

      # We remove any nil values
      config.topic_names.compact!

      unless config.topic_names.any?
        raise ConfigurationError, 'At least one topic must be configured'
      end

      @publisher_factory = PublisherFactory.new(config.topic_names)
    end

    def stub!
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory
      @publisher_factory = NullPublisherFactory.new
    end

    def publish(message, topic, &block)
      unless @publisher_factory
        raise ConfigurationError, 'PubsubClient must be configured or stubbed'
      end

      unless @publisher_factory.build[topic]
        raise ConfigurationError, 'Invalid topic given'
      end

      # The call to @publisher_factory has already been memoized.
      # No penalty for calling it again.
      @publisher_factory.build[topic].publish(message, &block)
    end
  end
end

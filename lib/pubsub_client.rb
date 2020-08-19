require 'pubsub_client/version'
require 'pubsub_client/null_publisher_factory'
require 'pubsub_client/publisher_factory'

module PubsubClient
  Error = Class.new(StandardError)
  CredentialsError = Class.new(Error)
  ConfigurationError = Class.new(Error)

  Config = Struct.new(:topic_name)

  class << self
    def configure(&block)
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory

      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set.'
      end

      config = Config.new
      yield config

      unless config.topic_name
        raise ConfigurationError, 'The topic_name must be configured.'
      end

      @publisher_factory = PublisherFactory.new(config.topic_name)
    end

    def stub!
      raise ConfigurationError, 'PubsubClient is already configured' if @publisher_factory
      @publisher_factory = NullPublisherFactory.new
    end

    def publish(message, &block)
      unless @publisher_factory
        raise ConfigurationError, 'PubsubClient must be configured or stubbed'
      end

      @publisher_factory.build.publish(message, &block)
    end
  end
end

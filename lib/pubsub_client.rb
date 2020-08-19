require 'pubsub_client/version'
require 'pubsub_client/publisher_factory'

module PubsubClient
  Error = Class.new(StandardError)
  CredentialsError = Class.new(Error)
  ConfigurationError = Class.new(Error)

  Config = Struct.new(:topic_name, :stubbed) do
    def stubbed?
      @stubbed || false
    end
  end

  class << self
    def configure(&block)
      yield config

      unless config.topic_name
        raise ConfigurationError, 'The topic_name must be configured.'
      end

      @publisher_factory = PublisherFactory.new(config.topic_name, config.stubbed)
    end

    def stub!
      config.stubbed = true
    end

    def publish(message, &block)
      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set.'
      end

      unless @publisher_factory
        raise ConfigurationError, 'PubsubClient.configure must be called'
      end

      @publisher_factory.build.publish(message, &block)
    end

    private

    def config
      @config ||= Config.new
    end
  end
end

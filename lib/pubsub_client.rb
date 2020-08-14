require 'pubsub_client/version'
require 'pubsub_client/publisher_factory'

module PubsubClient
  Error = Class.new(StandardError)
  CredentialsError = Class.new(Error)
  ConfigurationError = Class.new(Error)

  Config = Struct.new(:topic_name)

  class << self
    def config
      @config ||= Config.new
    end

    def configure(&block)
      yield config
    end

    def publish(message, &block)
      unless ENV['GOOGLE_APPLICATION_CREDENTIALS']
        raise CredentialsError, 'GOOGLE_APPLICATION_CREDENTIALS must be set.'
      end

      unless config.topic_name
        raise ConfigurationError, 'The topic_name must be configured.'
      end

      PublisherFactory.build(config.topic_name).publish(message, &block)
    end
  end
end

require 'pubsub_client/version'
require 'google/cloud/pubsub'

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

      pubsub = Google::Cloud::PubSub.new
      topic = pubsub.topic(config.topic_name)
      topic.publish_async(message, &block)
    end
  end
end

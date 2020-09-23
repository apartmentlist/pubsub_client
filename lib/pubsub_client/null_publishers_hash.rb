# frozen_string_literal: true

require_relative 'null_publisher'

module PubsubClient
  # The real object is a hash, so we mock out key-access behavior.
  # Passing any string will just return this instance of NullPublisher
  class NullPublishersHash
    def [](key)
      NullPublisher.new
    end
  end
end

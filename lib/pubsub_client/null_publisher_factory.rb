# frozen_string_literal: true

require_relative 'null_publishers_hash'

module PubsubClient
  # A null object to act as a publisher factory when clients are in dev or test
  class NullPublisherFactory
    def build
      NullPublishersHash.new
    end
  end
end

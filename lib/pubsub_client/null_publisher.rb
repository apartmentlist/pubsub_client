# frozen_string_literal: true

module PubsubClient
  # A null object to act as a publisher when clients are in dev or test
  class NullPublisher
    def publish(*)
      # no-op
    end
  end
end

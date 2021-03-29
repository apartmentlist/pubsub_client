# frozen_string_literal: true

class PubsubClient
  # A null object to act as a publisher when clients are in dev or test
  class NullPublisher
    # This is required so that this publisher maintains the same contract
    # as a real publisher.
    NullResult = Struct.new(:error) do
      def succeeded?
        true
      end
    end

    def publish(*, &block)
      yield NullResult.new
    end
  end
end

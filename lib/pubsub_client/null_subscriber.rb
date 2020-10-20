# frozen_string_literal: true

module PubsubClient
  # A null object to act as a subscriber when clients are in dev or test
  class NullSubscriber
    # This is required so that this publisher maintains the same contract
    # as a real publisher.
    NullResult = Struct.new(:data, :acknowledge!)

    def subscribe(*, &block)
      yield NullResult.new
    end
  end
end

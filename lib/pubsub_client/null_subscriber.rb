# frozen_string_literal: true

module PubsubClient
  # A null object to act as a subscriber when clients are in dev or test
  class NullSubscriber
    def subscribe(*, &block)
      yield 'message'
    end
  end
end

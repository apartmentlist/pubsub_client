# frozen_string_literal: true

require_relative 'null_subscriber'

class PubsubClient
  # A null object to act as a subscriber factory when clients are in dev or test
  class NullSubscriberFactory
    def build(*)
      NullSubscriber.new
    end
  end
end

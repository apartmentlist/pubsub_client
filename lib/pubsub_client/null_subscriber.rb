# frozen_string_literal: true

class PubsubClient
  # A null object to act as a subscriber when clients are in dev or test
  class NullSubscriber
    # This adds a subset of the available methods on the
    # Google::Cloud::PubSub::ReceivedMessage, which is what
    # gets yielded by the subscription when configuring the listener.
    # For a list of methods, see the following link:
    # https://googleapis.dev/ruby/google-cloud-pubsub/latest/Google/Cloud/PubSub/ReceivedMessage.html
    NullResult = Struct.new(:acknowledge!) do
      def data
        '{"key":"value"}'
      end

      def published_at
        Time.now
      end
    end

    def listener(*, &block)
      res = NullResult.new
      yield res.data, res
    end

    def subscribe
      # no-op
    end

    def on_error(&block)
      # no-op
    end
  end
end

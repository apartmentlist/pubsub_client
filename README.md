# PubsubClient

This is a wrapper around the `google-cloud-pubsub` gem. There are times when it is useful to stub out these resources while in development or test environment. This will allow clients to do just that. Additionally, this gem also handles proper memoization of these resources even in forked and/or multi-threaded environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pubsub_client'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pubsub_client

## Configuration

In order to use this gem, the environment variable `GOOGLE_APPLICATION_CREDENTIALS` must be set and point to the credentials JSON file.

If there are environments where setting up credentials is too burdensome and/or publishing messages is not desired, `PubsubClient` can be stubbed out with `PubsubClient.stub!`, e.g.

```ruby
if test_env?
  PubsubClient.stub!
end
```

## Usage

### Publishing

To publish a message to Pub/Sub, call `PubsubClient.publish(message, 'the-topic')`. This method takes any serializable object as an argument and yields a result object to a block. The `result` object has a method `#succeeded?` that returns `true` if the message was successfully published, otherwise `false`. In the latter case, there is a method `#error` that returns the error.

#### Example
```ruby
PubsubClient.publish(message, 'some-topic') do |result|
  if result.succeeded?
    puts 'yay!'
  else
    puts result.error
  end
end
```

### Subscribing

To subscribe to a topic, a client must first get a handle to the subscriber object. After doing so, a call to `subscriber.listener` will yield two arguments: the data (most clients will only need this) and the full Pub/Sub message (for anything more robust). Documentation for the full message can be found [here](https://googleapis.dev/ruby/google-cloud-pubsub/latest/Google/Cloud/PubSub/ReceivedMessage.html).

Optionally, a client can choose to handle exceptions raised by the subscriber. If a client chooses to do so, the listener **must** be configured before `on_error` since the latter needs a handler to the underlying listener. Additionally, exceptions will only be raised when the work inside the block is happening on the same thread. For instance, if the block enqueues a background worker and that worker raises an error, it will not be handled by the `on_error` block.

#### Example
```ruby
subscriber = PubsubClient.subscriber('some-subscription')

subscriber.listener(concurrency: 4, auto_ack: false) do |data, received_message|
  # Most clients will only need the first yielded arg.
  # It is the same as calling received_message.data
end

# Optional
subscriber.on_error do |ex|
  # Do something with the exception.
end

subscriber.subscribe # This will sleep
```

By default, the underlying subscriber will use a concurrency of `8` threads and will acknowledge all messages. If these defaults are acceptable to the client, no arguments need to be passed in the call to `listener`.
```ruby
subscriber.listener do |data, received_message|
  # Do something
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

To contribute, open a pull request against `main`. Note that once your changes have been made, you should _not_ manually modify the `version.rb` or `CHANGELOG` as these will get updated automatically as part of the release process.

To release a new version, after you have merged your changes into `main`:
1. Run the `gem-release` script. This can be found [here](https://github.com/apartmentlist/scripts/blob/main/bin/gem-release).
    ```
    path/to/gem-release [major/minor/patch] "Short message with changes"
    ```
    Note that the `Short message with changes` is what gets reflected in the releases of the repo.
1. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org). This step will update the `version.rb` and `CHANGELOG` files.

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pubsub_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pubsub_client/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PubsubClient project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pubsub_client/blob/master/CODE_OF_CONDUCT.md).

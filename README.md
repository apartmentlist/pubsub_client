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

In order to use this gem, the environment variable `GOOGLE_APPLICATION_CREDENTIALS` must be set and point to the credentials JSON file. Additionally, here are configuration settings that may need to be set:
- `topic_name` (required unless stubbed) - name of the Google Cloud Pub/Sub topic to publish messages to.

If there are environments where setting up credentials is too burdensome and/or publsihing events to the infrastructure is not desired, `PubsubClient` can be stubbed out with `PubsubClient.stub!`

E.g.

```ruby
if test_env?
  PubsubClient.stub!
else
  PubsubClient.configure do |config|
    config.topic_name = 'some-topic'
  end
end
```

## Usage

To publish a message to Pub/Sub, call `PubsubClient.publish(message)`. This method takes any serializable object as an argument and returns a result object. The `result` object has a method `#succeeded?` that returns `true` if the message was successfully published, otherwise `false`. In the latter case, there is a method `#error` that returns the error.

### Example
```ruby
result = PubsubClient.publish(message)
if result.succeeded?
  puts 'yay!'
else
  puts result.error
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pubsub_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pubsub_client/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PubsubClient project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pubsub_client/blob/master/CODE_OF_CONDUCT.md).

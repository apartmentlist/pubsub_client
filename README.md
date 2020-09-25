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

To publish a message to Pub/Sub, call `PubsubClient.publish(message, 'the-topic')`. This method takes any serializable object as an argument and yields a result object to a block. The `result` object has a method `#succeeded?` that returns `true` if the message was successfully published, otherwise `false`. In the latter case, there is a method `#error` that returns the error.

### Example
```ruby
PubsubClient.publish(message, 'some-topic') do |result|
  if result.succeeded?
    puts 'yay!'
  else
    puts result.error
  end
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

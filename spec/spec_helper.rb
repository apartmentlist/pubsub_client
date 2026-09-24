require 'bundler/setup'
require 'pubsub_client'
require 'googleauth'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Simulate resolvable Application Default Credentials (e.g. Workload Identity,
  # a key file, or gcloud user creds) by default. Individual examples override
  # this to simulate the no-credentials-available case.
  config.before do
    allow(Google::Auth).to receive(:get_application_default).and_return(double('credentials'))
  end
end

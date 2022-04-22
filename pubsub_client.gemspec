require_relative 'lib/pubsub_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'pubsub_client'
  spec.version       = PubsubClient::VERSION
  spec.authors       = ['Apartment List Platforms']
  spec.email         = ['platforms@apartmentlist.com']

  spec.summary       = %q{Google Pub/Sub Wrapper}
  spec.homepage      = 'https://github.com/apartmentlist/pubsub_client'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/apartmentlist/pubsub_client/blob/main/CHANGELOG.txt'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'google-cloud-pubsub', '~> 2.0'
  spec.add_runtime_dependency 'activesupport'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.13.1'

end

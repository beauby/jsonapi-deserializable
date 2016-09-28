version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-deserializable'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Deserialization of JSONAPI payloads.'
  spec.description   = 'DSL for validating incoming JSON API payloads and ' \
                       'building custom objects out of them.'
  spec.homepage      = 'https://github.com/beauby/jsonapi-deserializable'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.require_path  = 'lib'

  spec.add_dependency 'jsonapi-validations', '~> 0.1'

  spec.add_development_dependency 'rake', '>=0.9'
  spec.add_development_dependency 'rspec', '~>3.4'
end

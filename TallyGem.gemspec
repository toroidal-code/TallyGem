
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'TallyGem/version'

Gem::Specification.new do |spec|
  spec.name          = 'TallyGem'
  spec.version       = TallyGem::VERSION
  spec.authors       = ['Katherine Whitlock']
  spec.email         = ['toroidalcode@gmail.com']

  spec.summary       = 'A tallying program for quests'
  spec.homepage      = 'https://github.com/toroidal-code/TallyGem'
  spec.license       = 'GPL2'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'contracts'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'parslet'
  spec.add_dependency 'slop'
end

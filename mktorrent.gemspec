# mktorrent.gemspec
require 'rubygems'
Gem::Specification.new do |spec|
  spec.name = "mktorrent"
  spec.summary = "Create .torrent files easily with this gem"
  spec.description = "Create .torrent files easily with this gem. The code is ugly, but it works :)"
  spec.author = "Timothy Mukaibo"
  spec.email = "timothy@mukaibo.com"
  spec.homepage = "https://github.com/mukaibot/mktorrent"
  spec.license = 'MIT'
  spec.files = Dir['lib/*.rb']
  spec.test_files = Dir['test/*.rb']
  spec.version = '1.6.3'

  # Gems
  spec.add_dependency('bencode', '~> 0.8')
  spec.add_dependency('rake', '~> 10.1')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('minitest', '~> 5.0')
  spec.add_development_dependency('minitest-reporters', '~> 1.0')
  spec.add_development_dependency('rubygems-tasks', '0.2.4')
end

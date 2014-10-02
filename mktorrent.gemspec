# mktorrent.gemspec
require 'rubygems'
spec = Gem::Specification.new do |spec|
  spec.name = "mktorrent"
  spec.summary = "Create .torrent files easily with this gem"
  spec.description = "Create .torrent files easily with this gem. The code is ugly, but it works :)"
  spec.author = "Timothy Mukaibo"
  spec.email = "timothy@mukaibo.com"
  spec.homepage = "https://github.com/mukaibot/mktorrent"
  spec.add_dependency('bencode', '0.7.0')
  spec.files = Dir['lib/*.rb']
  spec.test_files = Dir['test/*.rb']
  spec.version = '1.0.1'
end

# Rakefile for mktorrent.rb. Use this to run tests.
require 'rake/testtask'
require 'rubygems/tasks'

Gem::Tasks.new

Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.warning = true
end

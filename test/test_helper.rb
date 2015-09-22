require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/reporters'

require File.join(File.dirname(__FILE__), '..', 'lib', 'mktorrent')
Dir.glob('test/support/*.rb').each { |r| load r }

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true),
]


TRACKER = "http://test.example.com"
WEBSEED = "http://seed.example.com/webseed"
EXPECTED_INFOHASH = "a5401756c2b3c001adfdfd1585712b80458e2d16"
VALIDPATH = File.expand_path("#{File.dirname(__FILE__)}/test_data")
VALIDFILEPATH = File.expand_path("#{File.dirname(__FILE__)}/test_data/sample_file1.vhd")
VALIDFILE2PATH = File.expand_path("#{File.dirname(__FILE__)}/test_data/sample_file2.vhd")
VALIDFILENAME = "randomfile.vhd"

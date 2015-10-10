require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/reporters'

require File.join(File.dirname(__FILE__), '..', 'lib', 'mktorrent')
Dir.glob('test/support/*.rb').each { |r| load r }

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true),
]


TRACKER = "http://test.example.com"
SNDTRACKER = "udp://test.tracker.tk:80"
THDTRACKER = "udp://open.testtracker.com:6500/announce"
WEBSEED = "http://seed.example.com/webseed"
EXPECTED_INFOHASH = "a8036d51ada8fb699c9f29d7861e5589f2d20cf9"
VALIDPATH = File.expand_path("#{File.dirname(__FILE__)}/test_data")
VALIDFILEPATH = File.expand_path("#{File.dirname(__FILE__)}/test_data/sample_file1.vhd")
VALIDFILE2PATH = File.expand_path("#{File.dirname(__FILE__)}/test_data/sample_file2.vhd")
VALIDFILENAME = "randomfile.vhd"

require 'minitest/autorun'
require File.join(File.dirname(__FILE__), '..', 'lib', 'mktorrent')

class MktorrentTest < Minitest::Test
  TRACKER = "http://test.example.com"
  VALIDFILEPATH = File.expand_path("#{File.dirname(__FILE__)}/test_data/sample_file1.vhd")
  VALIDFILE2PATH = File.expand_path("#{File.dirname(__FILE__)}/test_data/sample_file2.vhd")
  VALIDFILENAME = "randomfile.vhd"

  def setup
    @torrent = Torrent.new(TRACKER)
    # Lol. This is pretty bad :)
    fail "Could not find #{VALIDFILEPATH}" unless File.exist? VALIDFILEPATH
    fail "Could not find #{VALIDFILE2PATH}" unless File.exist? VALIDFILE2PATH
  end

  def test_create_torrent
    assert_equal @torrent.tracker, TRACKER
  end

  def test_add_file_with_invalid_file
    assert_raises(IOError) { @torrent.add_file("../tmp/bogusfile.vhd") }
  end

  def test_add_single_valid_file
    @torrent.add_file(VALIDFILEPATH)
    assert_equal @torrent.count, 1
    assert(@torrent.info[:info][:files].select { |f| f[:name] == VALIDFILENAME })
  end

  def test_add_another_valid_file
    @torrent.add_file(VALIDFILEPATH)
    @torrent.add_file(VALIDFILE2PATH)
    assert_equal 2, @torrent.count
  end

  def test_prevent_duplicate_file_from_being_added
    @torrent.add_file(VALIDFILEPATH)
    assert_raises(IOError) { @torrent.add_file(VALIDFILEPATH) }
  end

  def test_default_privacy
     @torrent.add_file(VALIDFILEPATH)
     assert_equal 0, @torrent.privacy
  end

  def test_set_privacy
     test_default_privacy
     @torrent.set_private
     assert_equal 1, @torrent.privacy
  end

end

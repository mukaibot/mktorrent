require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'mktorrent')

class MktorrentTest < Test::Unit::TestCase
  TRACKER = "http://test.example.com"
  VALIDFILEPATH = File.expand_path("#{File.dirname(__FILE__)}/../tmp/randomfile.vhd")
  VALIDFILENAME = "randomfile.vhd"
  VALIDFILE2PATH = File.expand_path("#{File.dirname(__FILE__)}/../tmp/randomfile2.vhd")

  def setup
    @torrent = Torrent.new(TRACKER)
  end

  def test_create_torrent
    assert_equal @torrent.tracker, TRACKER
  end

  def test_add_file_with_invalid_file
    assert_raise(IOError) { @torrent.add_file("../tmp/bogusfile.vhd") }
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
    assert_raise(IOError) { @torrent.add_file(VALIDFILEPATH) }
  end

end

require 'test_helper'

class MktorrentTest < Minitest::Test

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

  def test_add_second_tracker
    @torrent.add_tracker(SNDTRACKER)
    assert_equal 2, @torrent.tracker_list.count
  end

  def test_add_multiple_trackers
    @torrent.add_tracker(SNDTRACKER)
    @torrent.add_tracker(THDTRACKER)
    assert_equal SNDTRACKER, @torrent.tracker_list[1][0]
  end

  def test_add_valid_file_as_path_array
    @torrent.add_file(VALIDFILEPATH)
    path = @torrent.info[:info][:files].first[:path]
    assert_kind_of Array, path, "Path should be an array, not #{path}"
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

  def test_add_directory_increments_file_count
    @torrent.add_directory(VALIDPATH)
    assert_equal 3, @torrent.count
  end

  # When adding a directory, only the folder that's added (and everything below) should appear in the metadata
  def test_add_directory_uses_relative_paths
    assert [ VALIDFILEPATH, VALIDFILE2PATH ].each { |p| p.start_with?(VALIDPATH) }
    @torrent.add_directory(VALIDPATH)
    assert_equal @torrent.dirbase, VALIDPATH
    assert @torrent.files.each { |f| ! f[:path].join('/').start_with?(File.basename(File.dirname(VALIDPATH))) }
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

  def test_set_valid_webseed
    @torrent.set_webseed(WEBSEED)
    assert_equal WEBSEED, @torrent.webseed
  end

  def test_add_invalid_webseed
    assert_raises(ArgumentError) {
      @torrent.set_webseed('uheoatnhuetano')
    }
  end
end

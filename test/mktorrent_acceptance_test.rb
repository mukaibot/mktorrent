require 'test_helper'


# Run an external command against a torrent we generate for validation
class MktorrentAcceptanceTest < Minitest::Test

  def setup
    acceptance_command_file = File.open(File.join(File.dirname(__FILE__), 'acceptance_test_command')).read
    content = acceptance_command_file.split("\n")
    @command = content.delete_if { |line| line.start_with?("#") || line.strip.empty? }
    @torrent = create_torrent_for_test
  end

  def teardown
    if @torrent && @torrent.torrent_file && File.exist?(@torrent.torrent_file)
      FileUtils.rm @torrent.torrent_file
    end
  end

  def test_the_command_to_run
    assert_equal 1, @command.count, "Couldn't determine command to run"
  end

  def test_directory_has_data
    assert_operator Dir.entries(VALIDPATH).count, :>, 3 # At least one file, include '.' and '..'
  end

  def test_torrent_passes_acceptance
    assert File.exist?(@torrent.torrent_file)
    command = set_validation_command!
    output = `#{command}`
    result = $?
    assert result.success?, "Expected success but was #{result.to_i}. Command run: \n\n#{command}\nOutput: \n\n#{output}"
  end

  private
    def create_torrent_for_test
      torrent = Torrent.new('http://some.tracker.com')
      torrent.add_directory(VALIDPATH)
      torrent.write_torrent('torrent_test.torrent')
      torrent
    end

    def set_validation_command!
      @command.first.sub('<TORRENT_FILE>', @torrent.torrent_file).split(' ').shelljoin
    end
end

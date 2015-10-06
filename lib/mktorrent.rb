require 'bencode'
require 'digest/sha1'
require 'date'
require 'uri'

# Sample usage
#t = Torrent.new("http://your.tracker.com")
#t.add_file("path/to/file.foo")
#t.write_torrent("~/Downloads/mytorrent.torrent")

class Torrent
  attr_reader :torrent_file, :infohash
  attr_accessor :info, :filehashes, :piecelength, :files, :defaultdir, :tracker, :size, :privacy, :webseed

  # optionally initialize filename
  def initialize(tracker)
    @tracker = tracker
    @piecelength = 512 * 1024 # 512 KB
    @files = []
    @filehashes = []
    @size = 0
    @defaultdir = "torrent"
    @privacy = 0
    @webseed = ""
    @dirbase = ""
    build_the_torrent
  end

  def all_files
    if @files.any?
      @files.collect { |file| file[:path] }
    end
  end

  def count
    @files.count
  end

  def path_for_reading_pieces(f)
    if @dirbase.empty? # it's a single file torrent
      f = File.join(File.join(f))
    end
    f = File.join(@dirbase, f) unless @dirbase.empty?
    f
  end

  def read_pieces(files, length)
    buffer = ""
    files.each do |file|
      f = path_for_reading_pieces(file)
      next if File.directory?(f)
      File.open(f) do |fh|
        begin
          read = fh.read(length - buffer.length)

          # Make sure file not empty
          unless read.nil?
            if (buffer.length + read.length) == length
              yield(buffer + read)
              buffer = ""
            else
              buffer += read
            end
          end
        end until fh.eof?
      end
    end

    yield buffer
  end

  def build
    @info = {
      :announce => @tracker,
      :'creation date' => DateTime.now.strftime("%s"),
      :info => {
        :name => @defaultdir,
        :'piece length' => @piecelength,
        :files => @files,
        :private => @privacy,
      }
    }
    @info[:info][:pieces] = ""
    @info.merge({ "url-list" => @webseed }) unless @webseed.empty?
    if @files.count > 0
      read_pieces(all_files, @piecelength) do |piece|
        @info[:info][:pieces] += Digest::SHA1.digest(piece)
      end
    end
  end

  def write_torrent(filename)
    build_the_torrent
    @torrent_file = File.absolute_path(filename)
    open(@torrent_file, 'wb') do |file|
      file.write self.to_s
    end
    set_infohash
  end

  # Return the .torrent file as a string
  def to_s
    return "You must add at least one file." if(@files.count < 1)
    build_the_torrent unless (@info[:info][:files].count == @files.count)
    @info.bencode
  end

  def add_file(filepath)
    path_for_torrent = path_for_torrent_from_file(filepath)

    if((@files.select { |f| f[:path] == path_for_torrent } ).count > 0)
      raise IOError, "Can't add duplicate file #{File.basename(filepath)}"
    end

    # Remove a leading slash
    if ( ! @dirbase.empty?) && filepath[0] == '/'
      filepath = filepath.slice(1, filepath.length)
    end

    if File.exist?(filepath)
      @files << { path: path_for_torrent, length: File::open(filepath, "rb").size }
    elsif @dirbase && File.exist?(File.join(@dirbase, filepath))
      @files << { path: path_for_torrent, length: File::open(File.join(@dirbase, filepath), "rb").size }
    else
      raise IOError, "Couldn't access #{filepath}"
    end
  end

  def add_directory(path)
    path = Pathname.new(path)
    @dirbase = File.dirname(path) unless path.relative?
    add_directory_to_torrent(path)
  end

  def add_directory_to_torrent(path)
    # Using Dir.entries instead of glob so that non-escaped paths can be used
    Dir.entries(path).each do |entry|
      # Ignore unix current and parent directories
      next if entry == '.' or entry == '..'

      filename = File.join(path, entry).gsub(@dirbase, '') # Add a relative path
      if File.directory?(filename)
        add_directory_to_torrent(filename)
      else
        add_file(filename)
      end
    end
  end

  def set_webseed(url)
    validate_url!(url)
    @webseed = url
  end

  def set_private
    @privacy = 1
  end

  def set_public
    @privacy = 0
  end

  alias build_the_torrent build

  private
    def validate_url!(url)
      u = URI.parse(url)
      if u.scheme.nil? || u.host.nil?
        raise ArgumentError.new("#{url} is not a valid URL")
      end
    end

    def path_for_torrent_from_file(filepath)
      unless @dirbase.empty?
        filepath = filepath.sub(@dirbase, '')
      end

      # Remove leading blank item
      path_for_torrent = filepath.split('/') - [""]

      path_for_torrent
    end

    def set_infohash
      @infohash = Digest::SHA1.hexdigest @info[:info].bencode
    end
end

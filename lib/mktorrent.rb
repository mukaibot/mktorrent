require 'bencode'
require 'digest/sha1'
require 'date'
require 'uri'

# Sample usage
#t = Torrent.new("http://your.tracker.com")
#t.add_file("path/to/file.foo")
#t.write_torrent("~/Downloads/mytorrent.torrent")

class Torrent
  attr_accessor :info, :filehashes, :piecelength, :files, :defaultdir, :tracker, :size, :privacy, :webseeds

  # optionally initialize filename
  def initialize(tracker)
    @tracker = tracker
    @piecelength = 512 * 1024 # 512 KB
    @files = []
    @filehashes = []
    @size = 0
    @defaultdir = "torrent"
    @privacy = 0
    @webseeds = []
    build_the_torrent
  end

  def all_files
    unless @files.count < 1
      all_files = []
      @files.each do |f|
        all_files << f[:path]
      end
    end
    all_files
  end

  def count
    @files.count
  end

  def read_pieces(files, length)
    buffer = ""
    files.each do |f|
      puts "hashing #{f.join("/")}"
      File.open(f.join("/")) do |fh|
        begin
          read = fh.read(length - buffer.length)

          # Make sure file not empty
          if not read.nil?
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
    @info[:url-list] = @webseeds if @webseeds.any?
    if @files.count > 0
      i = 0
      read_pieces(all_files, @piecelength) do |piece|
        @info[:info][:pieces] += Digest::SHA1.digest(piece)
        i += 1
      end
    end
  end

  def write_torrent(filename)
    build_the_torrent
    open(filename, 'wb') do |torrentfile|
      torrentfile.write self.to_s
    end
    torrent_file = File.join(__DIR__, filename)
    puts "Wrote #{torrent_file}"
    torrent_file
  end

  # Return the .torrent file as a string
  def to_s
    return "You must add at least one file." if(@files.count < 1)
    build_the_torrent unless (@info[:info][:files].count == @files.count)
    @info.bencode
  end

  def add_file(filepath)
    if((@files.select { |f| f[:path].join('/') == filepath } ).count > 0)
      raise IOError, "Can't add duplicate file #{File.basename(filepath)}"
    end

    if File.exist?(filepath)
      @files << { path: filepath.split('/'), length: File::open(filepath, "rb").size }
    else
      raise IOError, "Couldn't access #{filepath}"
    end
  end

  def add_directory(path)
    # Using Dir.entries instead of glob so that non-escaped paths can be used
    Dir.entries(path).each do |entry|
      # Ignore unix current and parent directories
      next if entry == '.' or entry == '..'

      filename = File.join(path, entry)
      if File.directory?(filename)
        add_directory(filename)
      else
        add_file(filename)
      end
    end
  end

  def add_webseed(url)
    validate_url!(url)
    webseeds << url unless webseeds.include?(url)
  end

  # Need to read the files in @piecelength chunks and hash against that
  def hash_pieces(files)
    offset = 0
    f = File::open(file, "rb")
    @size += f.size
    while offset < f.size do
      offset += @piecelength
      STDOUT.write "\r#{File.basename(file)}: hashed #{(offset.to_f / f.size.to_f)*100}%"
      STDOUT.flush
    end
    return f.size
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
end

require 'bencode'
require 'digest/sha1'
require 'active_support'

# Sample usage
#t = Torrent.new("http://your.tracker.com")
#t.add_file("path/to/file.foo")
#t.write_torrent("~/Downloads/mytorrent.torrent")

# TODO
# Support tracker-list

class Torrent
  attr_accessor :info, :filehashes, :piecelength, :files, :defaultdir, :tracker, :size

  # optionally initialize filename
  def initialize(tracker)
    @tracker = tracker
    @piecelength = 512.kilobytes
    @files = []
    @filehashes = []
    @size = 0
    @defaultdir = "torrent"
    build_the_torrent
  end

  def count
    @files.count
  end

  def build
    @info = { :announce => @tracker,
              :info => { :name => @defaultdir,
                         :'piece length' => @piecelength,
                         :pieces => @filehashes.join,
                         :files => @files
                         #:private => 1,
                       } 
            }   
  end
    
  def write_torrent(filename)
    build_the_torrent
    open(filename, 'w') do |torrentfile|
      torrentfile.write self.to_s
      #torrentfile.puts self.to_s
    end
    puts "Wrote #{filename}"
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

    if File.exists?(filepath)
      filesize = hash_pieces(filepath)
      # TODO tidy the path up...
      @files << { path: filepath.split('/'), length: filesize }
    else
      raise IOError, "Couldn't access #{filepath}"
    end
  end

  def hash_pieces(file)
    offset = 0
    f = File::open(file, "rb")
    @size += f.size
    while offset < f.size do
      @filehashes << Digest::SHA1.digest(IO::binread(f, offset, @piecelength))
      offset += @piecelength
      STDOUT.write "\r#{File.basename(file)}: hashed #{(offset.to_f / f.size.to_f)*100}%"
      STDOUT.flush
    end
    return f.size
  end

  alias build_the_torrent build
end

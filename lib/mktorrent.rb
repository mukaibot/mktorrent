require 'bencode'
require 'digest/sha1'
require 'active_support'

# Sample usage
#t = Torrent.new
#t.mktorrent

class Torrent
  attr_accessor :announce, :info, :filehashes, :piecelength

  def initialize
    @piecelength = 512.kilobytes
    @filehashes = []
  end

  def mktorrent
    filename = "randomfile.vhd"
    @info = { :announce => "http://tracker.soupwhale.net",
              :info => { :name => filename,
                             :private => 1,
                             :'piece length' => @piecelength,
                             :path => filename,
                             :length => hash_pieces(filename),
                             :pieces => @filehashes.join
                           } 
            }   
    open("vhd.torrent", 'w') do |torrentfile|
      torrentfile.write @info.bencode
    end
    puts "Wrote vhd.torrent"
  end

  def hash_pieces(f)
    puts "Will read #{@piecelength} bytes at a time"
    offset = 0
    f = File::open(f, "rb")
    while offset < f.size do
      @filehashes << Digest::SHA1.digest(IO::binread(f, offset, @piecelength))
      offset += @piecelength
    end
    return f.size
  end

end

mktorrent
=========

A Ruby Gem for easily creating .torrent files.

To get started:

    git clone https://github.com/mukaibot/mktorrent.git
    gem build mktorrent.gemspec
    gem install mktorrent

Then in your Ruby code:

    require 'mktorrent'
    t = Torrent.new("http://your.tracker.com")
    t.add_file("path/to/your.file")
    t.add_file("path/to/another.file")
    t.add_tracker("upd://your.secondtracker.tk:80") # Optional
    t.add_tracker("http://third.tracker.com:6500/announce") # Optional
    t.add_directory("path/to/directory")
    t.add_webseed("http://your.webseed.com") # Optional!
    t.defaultdir = "Your Torrent"
    t.write_torrent("Yourtorrent.torrent")

## Development

Pull requests are very welcome!

### Running unit tests
The unit tests just use minitest
```
bundle exec rake test
```

### Running the acceptance tests

The acceptance tests run the command from the contents of
```
test/acceptance_test_command
```

On a torrent created from sample data. The string <TORRENT_FILE> will be replaced with the path to the created torrent. If the command exits with 0 the torrent is deemed to be valid.

A sample file could look like this:
```
/usr/local/Cellar/torrentcheck/1.00/bin/torrentcheck -t <TORRENT_FILE>
```

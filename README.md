# TallyGem
#### The Gem that Tallies!

## Installation

    $ gem install tallygem

## Usage
Currently TallyGem only works for Xenforo-based forums (such as sufficientvelocity.com).

Command-line options:
```
usage: tallygem [options] <thread-url>
    -s, --start            the post number to start with
    -e, --end              the post number to end with
    -k, --last-threadmark  auto-detect starting post based on last threadmark (default: true)
    -f, --format           Printer to use (bbcode (default), plain)
    -p, --partition        Strategy used for partitioning the vote (block (default), line, recursive)
    -v, --version          print the version
    -h, --help
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/toroidal-code/TallyGem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [GPLv2 License](http://opensource.org/licenses/MIT).


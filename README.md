# Vptree

[![Build Status](https://travis-ci.org/generall/vptree.svg)](https://travis-ci.org/generall/vptree)

Implementation of VP-tree (https://en.wikipedia.org/wiki/Vantage-point_tree) for fast kNN search with any measure function.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vptree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vptree

## Usage


Building tree:

```ruby
data = [[1,2], [2,1] , [2,2]]
# any measure, satisfies the triangle inequality, is allowed
# and may be passed as block
tree = Vptree::VPTree.new(data) # data - array of vectors of objects with special mixin, see https://github.com/generall/Distance-Measures
```
Quering tree:

```ruby
nearest = tree.find_k_nearest([3,3], 1)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/generall/vptree. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


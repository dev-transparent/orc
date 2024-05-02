# orc

## Reading

### Determine relevancy

* Open file at the end (last 16k) to get postscript and footer
* Use footer / statistics to determine if file is of interest

### Load data

* Open file at beginning of the file
* Use postscript and footer to lay out stripes
* Load stripe footer from stripe
* Load streams into memory
* Use column types to get relevant streams
* Iterate through each column row

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     orc:
       github: garymardell/orc
   ```

2. Run `shards install`

## Usage

```crystal
require "orc"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/garymardell/orc/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Gary Mardell](https://github.com/garymardell) - creator and maintainer

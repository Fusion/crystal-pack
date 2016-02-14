# crystal-pack

A library that aims to provide the pack() and unpack() methods to make
porting Ruby code to Crystal easier.

Far from complete so far at this covers a pretty broad feature set.

## Installation

Currently from source only:

1. `git clone https://github.com/Fusion/crystal-pack.git`
2. `lake` will build the small C dependency
3. `crystal build src/crystal-pack.cr`

### Why the C dependency?

Well, you could easily remove it from the project if you do not care about
the semantics of using "!" as a modifier (== "use native sizes")

## Usage

This library adds pack() and unpack() to String and Array.

Again, this is not fully developed yet.

## Development

The usual. If you wish to help, use Github's pull requests.

## Contributing

1. Fork it ( https://github.com/fusion/crystal-pack/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[Chris Ravenscroft]](https://github.com/fusion)  - creator, maintainer

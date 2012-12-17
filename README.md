# Casbah

A CAS server Rails Engine.

## Requirements

* Ruby on Rails 3.2 or greater
* Ruby 1.9.3+

## Installation

Add this line to your application's Gemfile:

    gem 'casbah'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install casbah

## Configuration

Configure Warden:

```ruby
# config/initializers/casbah.rb
Casbah.config.warden ->(mgr) {
  mgr.default_strategies :my_strategy
}
```

The configuration block is passed the whole Warden Manager
instance, so all Warden options should be available to you.

## TODOs

* Add better CAS §2.4 support
* Add support for CAS §2.5.4 - Proxy callback support
* Add support for CAS §2.6 - /proxyValidate
* Add support for CAS §2.7 - /proxy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

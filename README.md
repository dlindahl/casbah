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
Casbah.configure do |c|
  # Create a new Redis connection with whatever options you need
  c.redis = Redis.new( host:'localhost', port:6379 )

  # Configure Warden Manager according to your needs and their specifications
  c.warden ->(mgr) {
    mgr.default_strategies :my_strategy
  }

  # If your `ApplicationController` defines a `before_filter` that authenticates
  # all requests, you will need to tell Casbah the name of that filter so that
  # it will get skipped for `/login` page requests. Otherwise, your users would
  # never be able to login!
  c.authentication_filter = :authenticate! # Defaults to :require_login
```

You are responsible for properly creating and configuring your Redis connection.

In test environments, it is recommended that you use [MockRedis][mock_redis]

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

[mock_redis]: https://github.com/causes/mock_redis

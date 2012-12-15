if Rails.env.test?
  require 'mock_redis'

  RedisStore = MockRedis.new
else
  require 'redis'

  # TODO: Make this more configurable
  RedisStore ||= Redis.new(
    host: 'localhost',
    port: 6379
  )
end
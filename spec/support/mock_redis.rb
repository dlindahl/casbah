require 'mock_redis'

Casbah.config.redis = MockRedis.new

module RedisHelper
  def redis
    Casbah.config.redis
  end
end

RSpec.configure do |config|

  config.include RedisHelper

  config.after(:each) do
    Casbah.config.redis.flushall
  end

end

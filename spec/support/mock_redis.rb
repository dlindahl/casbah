RSpec.configure do |config|

  config.after(:each) { RedisStore.flushall }

end

class ServiceTicket < Ticket
  attr_reader :username, :url

  validates_presence_of :username, :url, allow_blank:false

  def initialize( params = {} )
    super

    @username = params[:username]
    @url      = params[:url]
  end

  def save
    if valid?
      RedisStore.pipelined do 
        RedisStore.hset    id, :url, url
        RedisStore.hset    id, :username, username
        RedisStore.expire  id, expire_time
      end
    end
  end

  def verify!( url )
    verified = url == RedisStore.hget( id, :url )

    destroy

    verified
  end

  class << self
    def find_by_id( id )
      if username = RedisStore.hget( id, :username )
        url = RedisStore.hget( id, :url )

        new id:id, username:username, url:url
      end
    end
    alias_method :find_by_ticket, :find_by_id
  end

end

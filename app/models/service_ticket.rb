class ServiceTicket < Ticket
  attr_reader :username, :url

  validates_presence_of :username, :url, allow_blank:false

  define_model_callbacks :save
  after_save :register_service

  def initialize( params = {} )
    super

    @username = params[:username]
    @url      = params[:url]
  end

  def save
    if valid?
      run_callbacks :save do
        redis.pipelined do 
          redis.hset    id, :url, url
          redis.hset    id, :username, username
          redis.expire  id, expire_time
        end
      end
    end
  end

  def verify!( url )
    verified = url == redis.hget( id, :url )

    destroy

    verified
  end

  def register_service
    Casbah::Service.registry.register url:url
  end

  class << self
    def find_by_id( id )
      if username = redis.hget( id, :username )
        url = redis.hget( id, :url )

        new id:id, username:username, url:url
      end
    end
    alias_method :find_by_ticket, :find_by_id
  end

end

ServiceTicket.id_prefix = 'ST-'

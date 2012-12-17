class LoginTicket < Ticket

  def save
    if valid?
      RedisStore.set id, 1
      RedisStore.expire id, expire_time
    end
  end

  def verify!
    verified = RedisStore.exists( id )

    destroy

    verified
  end

  class << self
    def find_by_id( id )
      new( id:id ) if RedisStore.exists( id )
    end
    alias_method :find_by_ticket, :find_by_id
  end

end

LoginTicket.id_prefix = 'LT-'

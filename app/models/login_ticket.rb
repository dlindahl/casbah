class LoginTicket < Ticket

  def save
    if valid?
      redis.set id, 1
      redis.expire id, expire_time
    end
  end

  def verify!
    verified = redis.exists( id )

    destroy

    verified
  end

  class << self
    def find_by_id( id )
      new( id:id ) if redis.exists( id )
    end
    alias_method :find_by_ticket, :find_by_id
  end

end

LoginTicket.id_prefix = 'LT-'

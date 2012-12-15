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

end

LoginTicket.id_prefix = 'LT-'

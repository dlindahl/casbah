class TicketGrantingTicket < Ticket
  attr_reader :username

  validates_presence_of :username, allow_blank:false

  def initialize( params = {} )
    super

    @username = params[:username]
  end

  def save
    if valid?
      redis.set id, @username
    end
  end

  def to_tgc( request )
    TicketGrantingCookie.new( self, request )
  end

  class << self
    def find_by_tgc!( tgc_id )
      return if tgc_id.blank?

      tgt_id = tgc_id.gsub( %r{\ATGC-}, id_prefix )

      if username = redis.get( tgt_id )
        new id:tgt_id, username:username
      else
        raise Casbah::TicketNotFoundError
      end
    end

    def find_by_tgc( *args )
      find_by_tgc!( *args )
    rescue Casbah::TicketNotFoundError
      # Noop
    end
  end

end

TicketGrantingTicket.id_prefix = 'TGT-'
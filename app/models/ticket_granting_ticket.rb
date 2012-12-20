class TicketGrantingTicket < Ticket
  attr_reader :username

  validates_presence_of :username, allow_blank:false

  TicketNotFoundError = Class.new(StandardError)

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
    def find_by_tgc( tgc_id )
      return if tgc_id.blank?

      tgt_id = tgc_id.gsub( %r{\ATGC-}, id_prefix )

      if username = redis.get( tgt_id )
        new id:tgt_id, username:username
      else
        raise TicketNotFoundError, 'Ticket-Granting Cookie not found'
      end
    end
  end

end

TicketGrantingTicket.id_prefix = 'TGT-'
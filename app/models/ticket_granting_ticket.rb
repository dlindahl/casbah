class TicketGrantingTicket < Ticket
  attr_reader :username

  TicketNotFoundError = Class.new(StandardError)

  def initialize( params = {} )
    super

    @username = params[:username]
  end

  class << self
    def find_by_tgc( tgc_id )
      return if tgc_id.blank?

      tgt_id = tgc_id.gsub( %r{\ATGC-}, 'TGT-' )

      if username = redis.get( tgt_id )
        new id:tgt_id, username:username
      else
        raise TicketNotFoundError, 'Ticket-Granting Cookie not found'
      end
    end
  end

end

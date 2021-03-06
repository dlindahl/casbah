class AuthorizationResponse
  include ActiveModel::Validations

  attr_accessor :ticket
  attr_reader :username, :service

  validates_presence_of :service, allow_blank:false
  validate :ticket_type
  validates_presence_of :ticket, allow_blank:false
  validate :verified_ticket

  InvalidRequest = 'INVALID_REQUEST'
  InvalidTicket  = 'INVALID_TICKET'
  InvalidService = 'INVALID_SERVICE'
  InternalError  = 'INTERNAL_ERROR'

  def initialize( params = {} )
    @service  = params[:service]
    @username = params[:username]
    @ticket   = params[:ticket]
  end

  def username
    @username || ticket.is_a?( Ticket ) ? ticket.username : nil
  end

  def status
    case failure_code
    when InvalidService then :unauthorized
    when InvalidTicket  then :forbidden
    when InvalidRequest then :bad_request
    end
  end

  def failure_code
    if errors[:base].any?
      InternalError
    elsif errors[:service_verification].any?
      InvalidService
    elsif errors[:ticket_type].any?
      InvalidTicket
    elsif errors[:service].any? || errors[:ticket].any?
      InvalidRequest
    end
  end

  def authorized?
    st = ServiceTicket.find_by_ticket( ticket )

    self.ticket = st if st

    valid?
  rescue StandardError => err
    errors.add :base, err.message

    false
  end

private

  def ticket_type
    if ticket.is_a? String
      if ticket =~ %r{\APT-}
        errors.add(:ticket_type, 'validation failed because a proxy ticket was passed')
      elsif errors.empty?
        errors.add(:ticket_type, "#{ticket} not recognized")
      end
    end
  end

  def verified_ticket
    if errors.empty?
      if ticket.verify!( service ) == false
        errors.add(:service_verification, 'failed')
      end
    end
  end

end

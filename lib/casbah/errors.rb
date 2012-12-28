module Casbah
  Error                = Class.new(StandardError)
  ValidationError      = Class.new(StandardError)
  ServiceNotFoundError = Class.new(StandardError)

  class SSOConfigError < Error
    def message
      "You have opted in to single sign-out behavior, but your Service model does not inherit from Casbah::Service::SingleSignOut"
    end
  end

  class TicketNotFoundError < Error
    def message
      'Ticket-Granting Cookie not found'
    end
  end
  
end

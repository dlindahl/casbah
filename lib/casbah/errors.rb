module Casbah
  Error = Class.new(StandardError)
  ValidationError = Class.new(StandardError)

  class SSOConfigError < Error
    def message
      "You have opted in to single sign-out behavior, but your Service model does not inherit from Casbah::Service::SingleSignOut"
    end
  end
  
end

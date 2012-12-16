class ServiceValidateController < ApplicationController

  respond_to :xml

  def index
    @response = AuthorizationResponse.new( params )

    if @response.authorized?( warden )
      respond_with @response, template:'service_validate/authorized'
    else
      respond_with @response, template:'service_validate/unauthorized', status:@response.status
    end
  end

private

  def warden
    request.env['warden']
  end

end

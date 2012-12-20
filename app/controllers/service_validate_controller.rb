class ServiceValidateController < ApplicationController

  respond_to :xml

  def index
    @response = AuthorizationResponse.new( params )

    if @response.authorized?
      respond_with @response, template:'service_validate/authorized'
    else
      respond_with @response, template:'service_validate/unauthorized', status:@response.status
    end
  end

end

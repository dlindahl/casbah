class ServiceValidateController < ApplicationController
  skip_before_filter Casbah.config.authentication_filter

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

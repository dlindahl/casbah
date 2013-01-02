class ValidateController < ApplicationController
  skip_before_filter Casbah.config.authentication_filter

  def index
    # TODO: Raise an InvalidRequestError and write a rescuer
    return render(text:'Missing required service parameter', status: :bad_request) unless params[:service]
    return render(text:'Missing required ticket parameter',  status: :bad_request) unless params[:ticket]
    return render(text:'Proxy Tickets are not supported',    status: :forbidden)   if params[:ticket] =~ %r{\APT-}

    raise NotImplementedError
  end

end

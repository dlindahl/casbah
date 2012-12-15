require 'addressable/uri'

class LoginController < ApplicationController

  respond_to :html, :xml, :json

  def index
    if params[:renew]
      renew
    elsif params[:gateway]
      gateway
    elsif params[:service]
      service
    else
      login
    end
  end

protected

  def renew
    if params[:renew] == 'true'
      render login_form
    else
      # TODO: Raise an InvalidRequestError and write a rescuer
      render text:'Invalid value for :renew parameter', status: :bad_request
    end
  end

  def gateway
    if params[:gateway] == 'true'
      if params[:service]
        if signed_in?
          @ticket = ServiceTicket.new( username:@sso_session.username, url:params[:service] )

          if @ticket.save
            redirect_to append_ticket( params[:service], @ticket.id )
          else
            raise NotImplementedError
          end
        else
          redirect_to params[:service]
        end
      else
        render login_form
      end
    else
      render text:'Invalid value for :gateway parameter', status: :bad_request
    end
  end

  def service
    if signed_in?
      @ticket = ServiceTicket.new( username:@sso_session.username, url:params[:service] )

      if @ticket.save
        redirect_to append_ticket( params[:service], @ticket.id )
      else
        raise NotImplementedError
      end
    else
      @ticket = LoginTicket.new

      render login_form
    end
  end

  def login
    if signed_in?
      render text:'already signed in'
    else
      render login_form
    end
  end

private

  def signed_in?
    @sso_session ||= TicketGrantingTicket.find_by_tgc( cookies['tgc'] )
  end

  def login_form
    { text:'[LOGIN FORM]' }
  end

  def signed_in_notice
    :create
  end

  def append_ticket( url, id )
    url = Addressable::URI.parse( url )

    url.query_values = (url.query_values||{}).merge( ticket:id )

    url.to_s
  end

end

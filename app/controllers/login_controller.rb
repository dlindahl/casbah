require 'addressable/uri'

class LoginController < ApplicationController

  respond_to :html, :xml, :json

  rescue_from Casbah::TicketNotFoundError, with: :login_expired

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

  def create
    # TODO: Raise an InvalidRequestError and write a rescuer
    return render(text:'Missing required lt parameter', status: :bad_request) unless params[:lt]
    return redirect_to_login_form('Invalid Login Ticket') unless LoginTicket.find_by_ticket( params[:lt] ).try(:verify!)
    return render(text:'Missing required username parameter', status: :bad_request) unless params[:username]
    return render(text:'Missing required password parameter', status: :bad_request) unless params[:password]

    if params[:warn] == 'true'
      render login_form
    elsif authorized?
      if @ticket
        redirect_to append_ticket( params[:service], @ticket.id )
      else
        render signed_in_notice
      end
    else
      redirect_to_login_form 'Invalid username or password'
    end
  end

  # Used as Warden's default failure app
  def authentication_failed
    Rails.logger.warn "Authentication attempt failed: #{request.env['warden.options']}"

    render text:'401 Unauthorized', status: :unauthorized
  end

  def login_expired
    redirect_to logout_url
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
      render login_form
    end
  end

  def login
    if signed_in?
      render already_signed_in
    else
      render login_form
    end
  end

private

  def warden
    request.env['warden']
  end

  def signed_in?
    @sso_session ||= TicketGrantingTicket.find_by_tgc! cookies['tgc']
  end

  def authorized?
    return unless warden.authenticate?

    @sso_session = TicketGrantingTicket.create( username:params[:username] )

    cookies['tgc'] = @sso_session.to_tgc( request ).to_cookie

    if params[:service]
      @ticket = ServiceTicket.create( username:params[:username], url:params[:service] )

      @ticket
    else
      true
    end
  end

  def login_form
    @ticket = LoginTicket.new

    @ticket.save

    :index
  end

  def already_signed_in
    :already_signed_in
  end

  def signed_in_notice
    :create
  end

  def append_ticket( url, id )
    url = Addressable::URI.parse( url )

    url.query_values = (url.query_values||{}).merge( ticket:id )

    url.to_s
  end

  def redirect_to_login_form( alert )
    url = login_form_url( service:params[:service] )

    redirect_to url, status: :see_other, alert:alert
  end

end

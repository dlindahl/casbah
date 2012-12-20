class LogoutController < ApplicationController

  def index
    redirect_to login_url unless cookies['tgc']

    if signed_in?
      @sso_session.destroy
    end

    cookies.delete 'tgc', domain:domain
  end

private

  def signed_in?
    @sso_session ||= TicketGrantingTicket.find_by_tgc( cookies['tgc'] )
  end

  def domain
    request.host =~ %r{localhost} ? nil : request.host
  end

end

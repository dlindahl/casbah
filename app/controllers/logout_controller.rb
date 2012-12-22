class LogoutController < ApplicationController

  def index
    if single_sign_out?
      cookies['sso'] = 1

      @services = Casbah::Service.registry.services

      render :single_sign_out
    else
      cookies.delete 'sso'

      warden.logout

      redirect_to login_url unless cookies['tgc']

      if signed_in?
        @sso_session.destroy
      end

      cookies.delete 'tgc', domain:domain
    end
  end

private

  def single_sign_out?
    Casbah.config.single_sign_out && !cookies['sso'].present?
  end

  def signed_in?
    @sso_session ||= TicketGrantingTicket.find_by_tgc( cookies['tgc'] )
  end

  def domain
    request.host =~ %r{localhost} ? nil : request.host
  end

  def warden
    request.env['warden']
  end

end

class TicketGrantingCookie

  def initialize( tgt, request )
    @ticket  = tgt
    @domain  = request.host
    @expires = nil
  end

  def value
    @ticket.id.gsub %r{\ATGT-}, 'TGC-'
  end

  def path
    Rails.application.routes.url_helpers.login_path.gsub('login', '')
  end

  def domain
    if @domain =~ %r{localhost}
      Rails.logger.warn 'Cannot set TGC cookie domain to localhost. Using nil instead.'

      nil
    else
      @domain
    end
  end

  def to_cookie
    {
      value:   value,
      domain:  domain,
      path:    path,
      expires: @expires
    }
  end
end

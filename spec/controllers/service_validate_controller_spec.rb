describe ServiceValidateController do
  let(:authenticated) { false }

  let(:warden) { double('warden', authenticate?:authenticated) }

  before { request.env['warden'] = warden }

  let(:username) { 'jdoe' }

  let(:service) { 'http://example.org/service/url?foo=123&baz=qux#hashtag' }

  let(:ticket) { ServiceTicket.new( id:'ST-123', username:username, url:service) }

  let(:params) { { service:service, ticket:ticket.id, format: :xml } }

  let(:make_request!) { get(:index, params) }

  subject { response }

  describe '2.5. /serviceValidate [CAS 2.0]' do
    render_views

    it 'MUST also generate and issue proxy-granting tickets when requested.', :untestable do
      # TODO: How is this requested?
    end

    it 'MUST NOT return a successful authentication if it receives a proxy ticket.' do
      params.merge! ticket:'PT-123'

      make_request!

      subject.status.should eq 403
    end

    it 'is RECOMMENDED that if /serviceValidate receives a proxy ticket, the error message in the XML response SHOULD explain that validation failed because a proxy ticket was passed to /serviceValidate.' do
      params.merge! ticket:'PT-123'

      make_request!

      subject.body.should match %r{Ticket type validation failed because a proxy ticket was passed}
    end

    describe '2.5.1. parameters' do
      context 'The following HTTP request parameters MAY be specified to /serviceValidate. They are case sensitive and MUST all be handled by /serviceValidate.' do

        describe 'service' do # the identifier of the service for which the ticket was issued, as discussed in Section 2.2.1.
          before do
            params.delete :service

            make_request!
          end

          it 'is [REQUIRED]' do
            subject.status.should eq 400
            subject.body.should match %r{Service can&#x27;t be blank}
          end
        end

        describe 'ticket' do # the service ticket issued by /login. Service tickets are described in Section 3.1.
          before do
            params.delete :ticket

            make_request!
          end

          it 'is [REQUIRED]' do
            subject.status.should eq 400
            subject.body.should match %r{Ticket can&#x27;t be blank}
          end
        end

        describe 'pgtUrl', :untestable do # the URL of the proxy callback. Discussed in Section 2.5.4.
          it 'is [OPTIONAL]' do
            # This functionality is tested elsewhere
          end
        end

        describe 'renew [OPTIONAL]', :untestable do
          context 'if this parameter is set' do
            it 'will only succeed if the service ticket was issued from the presentation of the user\'s primary credentials.' do
              # Unsure how to check for this
            end

            it 'will fail if the ticket was issued from a single sign-on session.' do
              # Unsure how to check for this
            end
          end
        end
      end
    end

    describe '2.5.2. response' do
      before do
        ServiceTicket.stub(:find_by_ticket)
          .with(ticket.id)
          .and_return ticket
      end

      it 'will return an XML-formatted CAS serviceResponse as described in the XML schema in Appendix A.' do
        make_request!

        subject.header['Content-Type'].should match %r{\Aapplication/xml}
      end

      context 'Below are example responses:' do
        context 'On ticket validation success:' do
          let(:authenticated) { true }

          it 'will respond accordingly' do
            make_request!

            doc = Nokogiri::XML( subject.body )
            body = doc.xpath('/cas:serviceResponse/cas:authenticationSuccess').first

            body.xpath('cas:user').first.content.should eq username
            # body.xpath('cas:proxyGrantingTicket').first.content.should match %r{PGTIOU-} # TODO
          end
        end

        context 'On ticket validation failure:' do
          it 'will respond accordingly' do
            make_request!

            doc = Nokogiri::XML( subject.body )
            body = doc.xpath('/cas:serviceResponse/cas:authenticationFailure').first

            body.attributes['code'].text.should eq 'INVALID_TICKET'
            body.text.should match %r{Ticket type ST-123 not recognized}
          end
        end
      end
    end

    describe '2.5.3. error codes' do
      context 'The following values MAY be used as the "code" attribute of authentication failure responses.' do
        context 'The following is the minimum set of error codes that all CAS servers MUST implement.' do
          specify 'INVALID_REQUEST' do # not all of the required request parameters were present
            params.delete :service

            make_request!

            doc = Nokogiri::XML( subject.body )
            body = doc.xpath('/cas:serviceResponse/cas:authenticationFailure').first

            body.attributes['code'].text.should eq 'INVALID_REQUEST'
            body.text.should match %r{Service can't be blank}
          end

          specify 'INVALID_TICKET' do # the ticket provided was not valid, or the ticket did not come from an initial login and "renew" was set on validation. The body of the <cas:authenticationFailure> block of the XML response SHOULD describe the exact details.
            ServiceTicket.stub(:find_by_ticket).and_return nil

            make_request!

            doc = Nokogiri::XML( subject.body )
            body = doc.xpath('/cas:serviceResponse/cas:authenticationFailure').first

            body.attributes['code'].text.should eq 'INVALID_TICKET'
            body.text.should match %r{Ticket type ST-123 not recognized}
          end

          specify 'INVALID_SERVICE' do # the ticket provided was valid, but the service specified did not match the service associated with the ticket. CAS MUST invalidate the ticket and disallow future validation of that same ticket.
            warden.stub(:authenticate?).and_return true

            ServiceTicket.new( id:'ST-123', username:username, url:'http://localhost').save

            ServiceTicket.any_instance.should_receive(:destroy)

            make_request!

            subject.status.should eq 401

            doc = Nokogiri::XML( subject.body )
            body = doc.xpath('/cas:serviceResponse/cas:authenticationFailure').first

            body.attributes['code'].text.should eq 'INVALID_SERVICE'
            body.text.should match %r{Service verification failed}
          end

          specify 'INTERNAL_ERROR' do # an internal error occurred during ticket validation
            warden.stub(:authenticate?).and_raise( StandardError, 'An error has occurred' )

            make_request!

            doc = Nokogiri::XML( subject.body )
            body = doc.xpath('/cas:serviceResponse/cas:authenticationFailure').first

            body.attributes['code'].text.should eq 'INTERNAL_ERROR'
            body.text.should match %r{An error has occurred}
          end

          context 'For all error codes' do
            it 'is RECOMMENDED that CAS provide a more detailed message as the body of the <cas:authenticationFailure> block of the XML response.', :untestable do
              # This is tested elsewhere
            end
          end
        end

        context 'Implementations MAY include others.', :untestable do
          # Nothing to test here
        end
      end
    end

    # describe '2.5.4. proxy callback' do
    #   context 'If a service wishes to proxy a client\'s authentication to a back-end service' do
    #     it 'must acquire a proxy-granting ticket.'

    #     context 'Acquisition of this ticket is handled through a proxy callback URL.' do
    #       it 'will uniquely and securely identify the back-end service that is proxying the client\'s authentication.'
    #       # The back-end service can then decide whether or not to accept the credentials based on the back-end service's identifying callback URL.
    #       it 'MUST be HTTPS'
          
    #       it 'CAS MUST verify both that the SSL certificate is valid and that its name matches that of the service.'

    #       context 'If the certificate fails validation, no proxy-granting ticket will be issued, and the CAS service response as described in Section 2.5.2' do
    #         it 'MUST NOT contain a <proxyGrantingTicket> block'

    #         context 'At this point, the issuance of a proxy-granting ticket is halted' do
    #           it 'service ticket validation will continue returning success or failure as appropriate'

    #           context 'If certificate validation is successful' do
    #             it 'issuance of a proxy-granting ticket proceeds'
    #           end
    #         end
    #       end
    #     end

    #     it 'uses an HTTP GET request to pass the HTTP request parameters "pgtId" and "pgtIou" to the pgtUrl'

    #     context 'If the HTTP GET returns an HTTP status code of 200 (OK)' do
    #       it 'MUST respond to the /serviceValidate (or /proxyValidate) request with a service response (Section 2.5.2) containing the proxy-granting ticket IOU (Section 3.4) within the <cas:proxyGrantingTicket> block.'
    #     end

    #     context 'If the HTTP GET returns any other status code, excepting HTTP 3xx redirects' do
    #       it 'MUST respond to the /serviceValidate (or /proxyValidate) request with a service response that MUST NOT contain a <cas:proxyGrantingTicket> block.'
    #       it 'MAY follow any HTTP redirects issued by the pgtUrl.'
    #       context 'the identifying callback URL provided upon validation in the <proxy> block' do
    #         it 'MUST be the same URL that was initially passed to /serviceValidate (or /proxyValidate) as the "pgtUrl" parameter.'
    #       end
    #     end

    #     describe 'The service, having received a proxy-granting ticket IOU in the CAS response, and both a proxy-granting ticket and a proxy-granting ticket IOU from the proxy callback' do
    #       it 'will use the proxy-granting ticket IOU to correlate the proxy-granting ticket with the validation response.'
    #       it 'The service will then use the proxy-granting ticket for the acquisition of proxy tickets as described in Section 2.7.'
    #     end
    #   end
    # end

    # describe '2.5.5. URL examples of /serviceValidate' do
    #   it 'Simple validation attempt:'
    #     # https://server/cas/serviceValidate?service=http%3A%2F%2Fwww.service.com&...
    #   it 'Ensure service ticket was issued by presentation of primary credentials:'
    #     # https://server/cas/serviceValidate?service=http%3A%2F%2Fwww.service.com&... ST-1856339-aA5Yuvrxzpv8Tau1cYQ7&renew=true

    #   it 'Pass in a callback URL for proxying:'
    #     # https://server/cas/serviceValidate?service=http%3A%2F%2Fwww.service.com&...
    # end
  end

end

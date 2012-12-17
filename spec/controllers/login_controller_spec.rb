describe LoginController do
  let(:authenticated) { false }

  let(:warden) { double('warden', authenticate?:authenticated) }

  before { request.env['warden'] = warden }

  let(:params) { { } }

  let(:username) { 'jdoe' }

  let(:service) { 'http://example.org/service/url?foo=123&baz=qux#hashtag' }

  subject { response }

  describe '2.1. /login as credential requestor' do
    let(:make_request!) { get( :index, params ) }

    context 'If the ticket-granting cookie keys to a valid ticket-granting ticket' do
      before do
        redis.set 'TGT-123', username

        params[:service] = service

        cookies[:tgc] = 'TGC-123'

        make_request!
      end

      it 'may issue a service ticket provided all the other conditions in this specification are met' do
        subject.status.should eq 302

        service_url  = Addressable::URI.parse( service )
        location_url = Addressable::URI.parse( response.location )

        location_url.query_values.keys.should include( *service_url.query_values.keys )
        location_url.query_values['ticket'].should match %r{ST-\w{256}}
        location_url.fragment.should eq service_url.fragment
      end
    end

    describe '2.1.1. parameters' do
      describe 'service [OPTIONAL]' do
        context 'If a service is not specified and' do
          context 'a single sign-on session does not yet exist' do
            before { make_request! }

            it 'SHOULD request credentials from the user to initiate a single sign-on session.' do
              expect(response).to render_template :index
            end
          end

          context 'a single sign-on session already exists' do
            before do
              redis.set 'TGT-123', username

              cookies[:tgc] = 'TGC-123'

              make_request!
            end

            it 'SHOULD display a message notifying the client that it is already logged in.' do
              subject.body.should == 'already signed in'
            end
          end
        end
      end

      describe 'renew [OPTIONAL]' do
        let(:params) { { renew:'true' } }

        context 'if this parameter is set, single sign-on will be bypassed. In this case' do
          before do
            redis.set 'TGT-123', username

            cookies[:tgc] = 'TGC-123'
          end

          specify 'CAS will require the client to present credentials regardless of the existence of a single sign-on session with CAS.' do
            make_request!

            expect(response).to render_template :index
          end

          specify 'This parameter is not compatible with the "gateway" parameter.' do
            params.merge! gateway:'true'

            make_request!

            expect(response).to render_template :index
          end

          specify 'Services redirecting to the /login URI and login form views posting to the /login URI SHOULD NOT set both the "renew" and "gateway" request parameters. Behavior is undefined if both are set.', :untestable do
            # Untestable
          end

          it 'is RECOMMENDED that CAS implementations ignore the "gateway" parameter if "renew" is set.' do
            params.merge! gateway:'true'

            make_request!

            expect(response).to render_template :index
          end

          it 'is RECOMMENDED that when the renew parameter is set its value be "true".' do
            params[:renew] = 'foobar'

            make_request!

            subject.status.should == 400
          end
        end
      end

      describe 'gateway [OPTIONAL]' do
        let(:params) { { gateway:'true', service:service } }

        context 'if this parameter is set' do
          before { make_request! }

          it 'will not ask the client for credentials.' do
            expect(response).to_not render_template :index
          end
        end

        context 'If the client has a pre-existing single sign-on session with CAS, or if a single sign-on session can be established through non-interactive means (i.e. trust authentication)' do
          before do
            redis.set 'TGT-123', username

            cookies[:tgc] = 'TGC-123'

            make_request!
          end

          it 'MAY redirect the client to the URL specified by the "service" parameter, appending a valid service ticket.' do
            response.should be_redirect

            service_url  = Addressable::URI.parse( service )
            location_url = Addressable::URI.parse( response.location )

            location_url.query_values.keys.should include( *service_url.query_values.keys )
            location_url.query_values['ticket'].should match %r{ST-\w{256}}
            location_url.fragment.should eq service_url.fragment
          end

          it 'also MAY interpose an advisory page informing the client that a CAS authentication has taken place.)', :untestable do
            # Not implemented
          end
        end

        context 'If the client does not have a single sign-on session with CAS, and a non-interactive authentication cannot be established' do
          before { make_request! }

          it 'MUST redirect the client to the URL specified by the "service" parameter with no "ticket" parameter appended to the URL.' do
            response.should redirect_to service
          end
        end

        context 'If the "service" parameter is not specified and "gateway" is set, the behavior of CAS is undefined' do
          it 'is RECOMMENDED that in this case, CAS request credentials as if neither parameter was specified.' do
            params.delete(:service)

            make_request!

            expect(response).to render_template :index
          end
        end

        it 'This parameter is not compatible with the "renew" parameter. Behavior is undefined if both are set', :untestable do
          # Untestable
        end

        it 'is RECOMMENDED that when the gateway parameter is set its value be "true".' do
          params[:renew] = 'foobar'

          make_request!

          subject.status.should == 400
        end
      end
    end

    describe '2.1.3. response for username/password authentication' do
      context 'When /login behaves as a credential requestor' do
        context 'In most cases' do
          render_views

          before do
            params.merge! warn:'true'

            make_request!
          end

          it 'will respond by displaying a login screen requesting a username and password.' do
            subject.body.should match %r{username}
            subject.body.should match %r{password}
          end

          it 'MUST include a form with the parameters, "username", "password", and "lt".' do
            subject.body.should match %r{username}
            subject.body.should match %r{password}
            subject.body.should match %r{lt}
          end

          it 'MAY also include the parameter, "warn".' do
            subject.body.should match %r{warn}
          end

          context 'If "service" was specified to /login,' do
            let(:params) { { service:service } }

            it '"service" MUST also be a parameter of the form, containing the value originally passed to /login.' do
              subject.body.should match %r{service}
            end
          end

          it 'The form MUST be submitted through the HTTP POST method to /login which will then act as a credential acceptor' do
            subject.body.should match %r{post}
          end
        end
      end
    end

    describe '2.1.4. response for trust authentication' do
      it 'will be highly deployer-specific in consideration of local policy and of the logistics of the particular authentication mechanism implemented.', :untestable do
        # Untestable
      end
    end
  end

  describe '2.2. /login as credential acceptor' do
    let(:make_request!) { post(:create, params) }

    let(:params) { { username:username, password:'foo', lt:'LT-123' } }

    before { LoginTicket.new( id:'LT-123' ).save }

    describe '2.2.1. parameters common to all types of authentication' do
      describe 'service [OPTIONAL]' do
        let(:authenticated) { true }

        before do
          params.merge! service:service

          make_request!
        end

        it 'MUST redirect the client to this URL upon successful authentication' do
          response.should be_redirect

          service_url  = Addressable::URI.parse( service )
          location_url = Addressable::URI.parse( response.location )

          location_url.query_values.keys.should include( *service_url.query_values.keys )
          location_url.query_values['ticket'].should match %r{ST-\w{256}}
          location_url.fragment.should eq service_url.fragment
        end
      end

      describe 'warn [OPTIONAL]' do
        before do
          params.merge! warn:'true'

          make_request!
        end

        context 'if this parameter is set' do
          it 'single sign-on MUST NOT be transparent.' do
            response.should_not be_redirect
          end

          it 'MUST be prompted before being authenticated to another service.' do
            expect(response).to render_template :index
          end
        end
      end

      describe '2.2.2. parameters for username/password authentication' do
        before do
          LoginTicket.new( id:'LT-123' ).save

          make_request!
        end

        describe 'username [REQUIRED]' do
          let(:params) { { password:'foo', lt:'LT-123' } }

          it 'MUST be passed to /login' do
            subject.status.should eq 400
            subject.body.should match %r{username}
          end
        end

        describe 'password [REQUIRED]' do
          let(:params) { { username:username, lt:'LT-123' } }

          it 'MUST be passed to /login' do
            subject.status.should eq 400
            subject.body.should match %r{password}
          end
        end

        describe 'lt [REQUIRED]' do
          let(:params) { { username:username, password:'password' } }

          it 'MUST be passed to /login' do
            subject.status.should eq 400
            subject.body.should match %r{lt}
          end
        end
      end

      describe '2.2.3. parameters for trust authentication' do
        it 'There are no REQUIRED HTTP request parameters for trust authentication. Trust authentication may be based on any aspect of the HTTP request.', :untestable do
          # Untestable
        end
      end

      describe '2.2.4. response' do
        context 'One of the following responses MUST be provided by /login when it is operating as a credential acceptor.' do
          describe 'successful login' do
            let(:params) { { service:service, username:username, password:'foo', lt:'LT-123' } }

            let(:authenticated) { true }

            before { make_request! }

            it 'MUST redirect the client to the URL specified by the "service" parameter in a manner that will not cause the client\'s credentials to be forwarded to the service.' do
              subject.location.should_not include username
            end

            it 'MUST result in the client issuing a GET request to the service.' do
              subject.location.should_not be_nil
            end

            it 'MUST include a valid service ticket, passed as the HTTP request parameter, "ticket".' do
              service_url  = Addressable::URI.parse( service )
              location_url = Addressable::URI.parse( subject.location )

              location_url.query_values.keys.should include( *service_url.query_values.keys )
              location_url.query_values['ticket'].should match %r{ST-\w{256}}
              location_url.fragment.should eq service_url.fragment
            end

            context 'If "service" was not specified' do
              let(:params) { { username:username, password:'foo', lt:'LT-123' } }

              it 'MUST display a message notifying the client that it has successfully initiated a single sign-on session.' do
                expect(response).to render_template :create
              end
            end
          end

          describe 'failed login' do
            let(:params) { { username:username, password:'foo', lt:'LT-123' } }

            before { make_request! }

            it 'MUST return to /login as a credential requestor.' do
              subject.location.should == login_form_url
            end

            it 'is RECOMMENDED in this case that the CAS server display an error message be displayed to the user describing why login failed (e.g. bad password, locked account, etc.)' do
              flash[:alert].should == 'Invalid username or password'
            end

            it 'MAY provide an opportunity for the user to attempt to login again.' do
              subject.status.should eq 303
              subject.location.should eq login_form_url
            end
          end
        end
      end
    end
  end

end

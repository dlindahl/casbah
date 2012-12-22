describe LogoutController do
  before do
    TicketGrantingTicket.stub( :find_by_tgc )
      .and_return double('TGT', destroy:true)
  end

  let(:warden) { double('warden', logout:true) }

  before { request.env['warden'] = warden }

  let(:params) { { } }

  let(:url) { 'http://example.org/my_return?url=test#hashtag' }

  let(:make_request!) { get( :index, params ) }

  subject { response }

  describe '/logout' do
    before { cookies['tgc'] = 'TGC-123' }

    context 'with single sign out enabled' do
      before do
        Casbah.config.stub(:single_sign_out).and_return true
      end

      context 'and no previous SSO request' do
        before { make_request! }

        it { should render_template :single_sign_out }
      end

      context 'and a previous SSO request' do
        before do
          cookies['sso'] = 1

          make_request!
        end

        it { should render_template :index }
      end

    end

    context 'with single sign out disabled' do
      before do
        Casbah.config.stub(:single_sign_out).and_return false

        make_request!
      end

      it { should render_template :index }
    end
  end

  describe '2.3. /logout' do
    before do
      cookies['tgc'] = 'TGC-123'

      cookies['sso'] = 1

      make_request!
    end

    it 'MUST destroy the ticket-granting cookie' do
      cookies['tgc'].should be_nil
    end

    context 'subsequent requests to /login' do
      it 'will not obtain service tickets until the user again presents primary credentials (and thereby establishes a new single sign-on session).', :untestable do
        # Untestable in this controller spec
      end
    end

    describe '2.3.1. parameters' do
      context 'The following HTTP request parameter MAY be specified to /logout. It is case sensitive and SHOULD be handled by /logout.' do
        describe 'url [OPTIONAL]' do
          context 'if "url" is specified' do
            let(:params) { { url:url } }

            render_views

            it 'SHOULD be on the logout page with descriptive text.' do
              subject.body.should include url
            end
          end
        end
      end
    end

    describe '2.3.2. response' do
      render_views

      it 'MUST display a page stating that the user has been logged out.' do
        subject.body.should include 'You have been signed out'
      end

      context 'If the "url" request parameter is implemented' do
        let(:params) { { url:url } }

        it 'SHOULD also provide a link to the provided URL as described in Section 2.3.1.' do
          subject.body.should include url
        end
      end
    end
  end
end

describe ValidateController do

  let(:params) { { } }

  let(:service) { URI.encode('http://example.org/my_service/url') }

  let(:make_request!) { get( :index, params ) }

  subject { response }

  describe '2.4. /validate [CAS 1.0]' do
    it 'MUST respond with a ticket validation failure response when a proxy ticket is passed to /validate.' do
      params.merge! service:service, ticket:'PT-123'

      make_request!

      subject.status.should == 403
    end

    describe '2.4.1. parameters' do
      context 'The following HTTP request parameters MAY be specified to /validate. They are case sensitive and MUST all be handled by /validate.' do
        describe 'service' do # the identifier of the service for which the ticket was issued, as discussed in Section 2.2.1.
          before { make_request! }

          it 'is [REQUIRED]' do
            subject.status.should eq 400
            subject.body.should eq 'Missing required service parameter'
          end
        end

        describe 'ticket' do
          before do
            params.merge! service:service

            make_request!
          end

          it 'is [REQUIRED]' do # the service ticket issued by /login. Service tickets are described in Section 3.1.
            subject.status.should eq 400
            subject.body.should eq 'Missing required ticket parameter'
          end
        end

        describe 'renew [OPTIONAL]' do
          let(:params) { { service:service, ticket:'foo', renew:'true' } }

          context 'if this parameter is set' do
            it 'will only succeed if the service ticket was issued from the presentation of the user\'s primary credentials.', :untestable do
              # TODO: How can you tell the difference?
            end

            it 'will fail if the ticket was issued from a single sign-on session.', :untestable do
              # TODO: How can you tell the difference?
            end
          end
        end
      end
    end

    describe '2.4.2. response', :untestable do
      context '/validate will return one of the following two responses:' do
        context 'On ticket validation success:' do
          it 'will respond accordingly' do
            # yes<LF>
            # username<LF>
          end
        end

        context 'On ticket validation failure:' do
          it 'will respond accordingly' do
            # no<LF>
            # <LF>
          end
        end
      end
    end

    describe '2.4.3. URL examples of /validate', :untestable do
      context 'Simple validation attempt:' do
        # https://server/cas/validate?service=http%3A%2F%2Fwww.service.com&ticket=...
      end

      context 'Ensure service ticket was issued by presentation of primary credentials:' do
        # https://server/cas/validate?service=http%3A%2F%2Fwww.service.com&ticket=...
      end
    end
  end

end

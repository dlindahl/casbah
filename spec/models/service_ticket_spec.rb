describe ServiceTicket do
  let(:id) { 'ST-123' }

  let(:username) { 'jdoe' }

  let(:url) { 'http://example.org/service/url?foo=123&baz=qux#hashtag' }

  let(:instance) { described_class.new( id:id, username:username, url:url ) }

  its(:id_prefix) { should == 'ST-' }

  describe '#save' do
    subject { instance.save }

    after { Casbah::Service.registry.clear! }

    context 'with a valid ticket' do
      it 'should save the ticket' do
        subject

        redis.hget( id, :username ).should eq username
        redis.hget( id, :url ).should eq url
        redis.ttl( id ).should eq 5.minutes
      end

      context 'for an unknown service' do
        it 'should register the service' do
          Casbah::Service.registry
            .should_receive(:register)
            .with{ |svc| svc.url == 'http://example.org' }

          subject
        end
      end

      context 'for a known service' do
        before do
          Casbah::Service.registry.register url:url
        end

        it 'should not re-register the service' do
          Casbah::Service.registry
            .should_receive(:register).never

          subject
        end
      end
    end

    context 'with an invalid ticket' do
      let(:instance) { described_class.new }

      it 'should not save the ticket' do
        subject

        redis.keys('*').should be_empty
      end
    end
  end

  describe '#verify!' do
    subject { instance.verify!( verify_url ) }

    before { instance.save }

    context 'with a matching URL' do
      let(:verify_url) { url }

      it { should be_true }

      it 'must invalidate the ticket' do
        instance.should_receive(:destroy)

        subject
      end
    end

    context 'with a mismatched URL' do
      let(:verify_url) { 'http://localhost' }

      it { should be_false }

      it 'must invalidate the ticket' do
        instance.should_receive(:destroy)

        subject
      end
    end
  end

  describe '.find_by_id' do
    subject { described_class.find_by_id 'ST-123' }

    context 'with a known ID' do
      before do
        redis.hset id, :username, username
        redis.hset id, :url, url
      end

      it 'should find the ticket' do
        subject.should be_a described_class
        subject.id.should eq id
        subject.username.should eq username
        subject.url.should eq url
      end
    end

    context 'with an unknown ID' do
      it 'should not find the ticket' do
        subject.should be_nil
      end
    end
  end

  describe 'CAS protocol specification' do
    subject { instance }

    describe '3.1' do

      describe '3.1.1' do
        before { subject.save }

        it 'is only valid for the service identifier that was specified to /login when they were generated.' do
          subject.verify!( 'http://localhost' ).should be_false
        end

        it 'service identifier SHOULD NOT be part of the service ticket.' do
          subject.id.include?( url ).should be_false
        end

        it 'MUST only be valid for one ticket validation attempt.' do
          subject.verify! url

          subject.verify!( url ).should be_false
        end

        context 'When validation was successful' do
          it 'MUST then invalidate the ticket, causing all future validation attempts of that same ticket to fail.' do
            subject.verify! url

            redis.keys('*').should be_empty
          end
        end

        context 'When validation was unsuccessful' do
          it 'MUST then invalidate the ticket, causing all future validation attempts of that same ticket to fail.' do
            subject.verify! 'http://localhost'

            redis.keys('*').should be_empty
          end
        end

        it 'SHOULD expire unvalidated service tickets in a reasonable period of time after they are issued.' do
          redis.ttl( subject.id ).should eq 5.minutes
        end

        context 'If a service presents for validation an expired service ticket' do
          before { redis.del( subject.id ) }

          it 'MUST respond with a validation failure response.' do
            subject.verify!( url ).should be_false
          end
        end

        context 'it is RECOMMENDED that the validation response include a descriptive message explaining why validation failed.', :untestable do
          # Not implemented
        end

        it 'is RECOMMENDED that the duration a service ticket is valid before it expires be no longer than five minutes.' do
          described_class.expire_time.should be <= 5.minutes
        end

        context 'Local security and CAS usage considerations' do
          it 'MAY determine the optimal lifespan of unvalidated proxy tickets.', :untestable do
            # Not implemented
          end
        end

        it 'MUST contain adequate secure random data so that a ticket is not guessable.' do
          described_class.new.id.should match %r{\A[A-Z]+-\w{256}}
        end

        it 'MUST begin with the characters, "ST-".' do
          described_class.new.id.should match %r{\AST-.+}
        end

        # TODO: Not the best test, but its better than nothing I suppose
        it 'MUST be able to accept service tickets of up to 32 characters in length.' do
          described_class.new.id.match( /\A[A-Z]+-(?<key>.+)/ )[:key].size.should be > 32
        end

        it 'is RECOMMENDED that services support service tickets of up to 256 characters in length.' do
          described_class.new.id.match( /\A[A-Z]+-(?<key>.+)/ )[:key].size.should == 256
        end
      end

    end

  end

end
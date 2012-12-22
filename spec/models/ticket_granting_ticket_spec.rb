describe TicketGrantingTicket do
  let(:id) { 'TGT-123' }

  let(:username) { 'jdoe' }

  let(:instance) { described_class.new( id:id, username:username ) }

  describe '#save' do
    subject { instance.save }

    context 'with a valid ticket' do
      it 'should save the ticket' do
        subject

        redis.get( id ).should eq username
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

  describe '#to_tgc' do
    let(:id) { 'TGT-123' }

    let(:request) { double('request').as_null_object }

    subject { instance.to_tgc( request ) }

    it { should be_a TicketGrantingCookie }
  end

  describe '.find_by_tgc!' do
    let(:tgc) { 'TGC-123' }

    subject { described_class.find_by_tgc!( tgc ) }

    context 'with a known value' do
      before { Casbah.config.redis.set( id, username ) }

      it { should be_a described_class }
    end

    context 'with an unknown value' do
      it 'should raise an error' do
        expect{ subject }.to raise_error Casbah::TicketNotFoundError
      end
    end

    context 'with a nil value' do
      let(:tgc) { nil }

      it { should be_nil }
    end
  end

  describe '.find_by_tgc' do
    subject { described_class.find_by_tgc 123 }
    context 'with a known value' do
      it 'should delegate to .find_by_tgc!' do
        described_class.should_receive(:find_by_tgc!).with( 123 )

        subject
      end
    end

    context 'with an unknown value' do
      it 'should delegate to .find_by_tgc!' do
        described_class.should_receive(:find_by_tgc!)
          .and_raise( Casbah::TicketNotFoundError )

        subject.should be_nil
      end
    end
  end
end
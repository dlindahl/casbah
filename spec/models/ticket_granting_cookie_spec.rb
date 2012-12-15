describe TicketGrantingCookie do
  let(:ticket) { double('tgt', id:'TGT-123') }

  let(:host) { 'example.org' }

  let(:request) { double('request', host:host) }

  let(:instance) { described_class.new( ticket, request ) }

  describe '#value' do
    subject { instance.value }

    it { should == 'TGC-123' }
  end

  describe '#path' do
    subject { instance.path }

    it { should == '/cas/' }
  end

  describe '#domain' do
    subject { instance.domain }

    it { should == host }

    context 'with a localhost request' do
      let(:host) { 'localhost' }

      it { should be_nil }
    end
  end

  describe '#to_cookie' do
    subject { instance.to_cookie }

    it { should include(value:   'TGC-123') }
    it { should include(domain:  'example.org') }
    it { should include(path:    '/cas/') }
    it { should include(expires: nil) }
  end

end

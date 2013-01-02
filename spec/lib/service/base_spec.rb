describe Casbah::Service::Base do

  let(:url) { 'https://me:pass@qct01.dc.customink.com:3000/foo/bar?qux=meh&abc=123#hashtag' }

  let(:instance) { described_class.new }

  it { should respond_to(:id) }
  it { should respond_to(:url) }

  describe '#valid?' do
    subject { instance.valid? }

    it { should be_false }    
  end

  describe '#id' do
    subject { described_class.new(url:url).id }

    it { should == 'service.https://qct01.dc.customink.com:3000' }
  end

  describe '#to_s' do
    subject { instance.to_s }

    it { should == instance.id }
  end

  describe '#url=' do
    before { instance.url = url }

    subject { instance.url }

    context 'with a valid url' do
      it { should == 'https://qct01.dc.customink.com:3000' }
    end

    context 'with an invalid url' do
      let(:url) { 'foo' }

      it { should be_nil }
    end
  end

  describe '#attributes' do
    subject { instance.attributes }

    it { should include('id') }
    it { should include('url') }
  end

  describe '#destroy' do
    before do
      Casbah::Service.registry.should_receive(:delete).with('service.')
    end

    it 'should destroy the instance' do
      instance.destroy
    end
  end

  describe '#register' do
    subject { instance.register }

    context 'when valid' do
      let(:instance) { described_class.new(url:url) }

      before do
        Casbah::Service.registry.should_receive(:register).with instance
      end

      it 'should register the service' do
        subject
      end
    end

    context 'when not valid' do
      before do
        Casbah::Service.registry.should_receive(:register).never
      end

      it 'should not register the service' do
        subject
      end
    end
  end

end

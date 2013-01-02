describe Casbah::Service::SingleSignOut do

  let(:url) { 'https://me:pass@qct01.dc.customink.com:3000/foo/bar?qux=meh&abc=123#hashtag' }

  let(:path) { nil }

  let(:default) { '/log_me_out' }

  let(:instance) { described_class.new( url:url, logout_path:path ) }

  before do
    Casbah.config.stub(:service_options)
      .and_return logout_path:default
  end

  describe '#logout_path' do
    subject { instance.logout_path }

    context 'with a specific value' do
      let(:path) { '/foo' }

      it { should == path }
    end

    context 'with a blank value' do
      let(:path) { '' }

      it { should == default }
    end

    context 'with no specific value' do
      it 'should fallback to the service default' do
        subject.should == default
      end
    end
  end

  describe '#logout_url' do
    subject { instance.logout_url }

    it { should == 'https://qct01.dc.customink.com:3000/log_me_out' }
  end

  describe '#attributes' do
    subject { instance.attributes }

    it { should include('logout_path') }
  end

end

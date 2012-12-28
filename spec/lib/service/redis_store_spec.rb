describe Casbah::Service::RedisStore do

  let(:model) { Casbah::Service::Base }

  let(:service) { model.new(id:'service.123', url:'http://example.org') }

  let(:instance) { described_class.new(model) }

  describe '#fetch' do
    subject { instance.fetch( service.id ) }

    context 'with a known ID' do
      before do
        Casbah.config.redis.hset service.id, :url, service.url
      end

      it 'should retrieve the instance' do
        subject.should be_a model
        subject.id.should eq service.id
        subject.url.should eq service.url
      end
    end

    context 'with an unknown ID' do
      it 'should raise an error' do
        expect { subject }.to raise_error Casbah::ServiceNotFoundError
      end
    end
  end

  describe '#register' do
    it 'should store the instance' do
      instance.register service

      Casbah.config.redis.exists( service.id ).should be_true
    end
  end

  describe '#delete' do
    before { instance.register service }

    it 'should delete the instance' do
      instance.delete service.id

      Casbah.config.redis.exists( service.id ).should be_false
    end
  end

  describe '#services' do
    before { instance.register service }

    it 'should return all registered services' do
      instance.services.should be_a Array
      instance.services.first.should be_a model
      instance.services.first.id.should == service.id
    end
  end

  describe '#registered?' do
    before { instance.register service }

    subject { instance.registered? service.id }

    it { should be_true }
  end

  describe '#clear!' do
    before do
      instance.register service

      Casbah.config.redis.set 'test', 1
    end

    subject { instance.clear! }

    it 'should delete all registered services' do
      subject

      Casbah.config.redis.keys('*').size.should eq 1
      Casbah.config.redis.keys('service.*').size.should eq 0
    end
  end

  describe '#serialize' do
    subject { instance.serialize( service ) }

    it { should include('url') } 
    it { should_not include('id') }
  end

end

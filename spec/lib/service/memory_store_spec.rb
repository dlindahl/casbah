describe Casbah::Service::MemoryStore do
  let(:model) { Casbah::Service::Base }

  let(:service) { model.new(id:'service.123', url:'http://example.org') }

  let(:instance) { described_class.new model }

  describe '#fetch' do
    before { instance.register service }

    subject { instance.fetch( service.id ) }

    it 'should retrieve the instance' do
      subject.should be_a model
      subject.id.should == service.id
    end
  end

  describe '#register' do
    before { instance.register service }

    subject { instance.services }

    it 'should store the instance' do
      subject.collect(&:id).should include service.id
    end
  end

  describe '#delete' do
    before { instance.register service }

    it 'should delete the instance' do
      instance.delete service.id

      instance.services.should be_empty
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

  describe '#clear!' do
    before { instance.register service }

    subject { instance.clear! }

    it 'should delete all registered services' do
      subject

      instance.services.should be_empty
    end
  end

end

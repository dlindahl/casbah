describe Casbah::Service::AbstractStore do
  let(:instance) { described_class.new( MyService ) }

  let(:model) { Class.new( Casbah::Service::Base ) }

  before { stub_const 'MyService', model }

  subject { instance }

  describe '#fetch' do
    it 'should raise an error' do
      expect{ subject.fetch }.to raise_error NotImplementedError
    end
  end

  describe '#register' do
    it 'should raise an error' do
      expect{ subject.register }.to raise_error NotImplementedError
    end
  end

  describe '#delete' do
    it 'should raise an error' do
      expect{ subject.delete }.to raise_error NotImplementedError
    end
  end

  describe '#services' do
    it 'should raise an error' do
      expect{ subject.services }.to raise_error NotImplementedError
    end
  end

  describe '#registered?' do
    before { subject.should_receive(:fetch).with(123) }

    it 'should detect if the ID is registered' do
      subject.registered? 123
    end
  end

  describe '#clear!' do
    it 'should raise an error' do
      expect{ subject.clear! }.to raise_error NotImplementedError
    end
  end

  describe '#serialize' do
    let(:service) { double('service') }

    it 'should serialize the model' do
      subject.serialize( service ).should == service
    end
  end

  describe '#deserialize' do
    subject { instance.deserialize(entity) }

    context 'with a valid entity' do
      let(:entity) { { url:'http://example.org' } }

      it 'should return the entity' do
        subject.should be_a MyService
      end
    end

    context 'with an invalid entity' do
      let(:entity) { {} }

      it 'should raise an error' do
        expect{ subject }.to raise_error Casbah::ValidationError
      end
    end
  end

end
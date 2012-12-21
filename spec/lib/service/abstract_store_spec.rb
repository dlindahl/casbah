describe Casbah::Service::AbstractStore do
  let(:model) { double('model').as_null_object }

  subject { described_class.new( model ) }

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

end
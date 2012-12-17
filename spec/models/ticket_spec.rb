describe Ticket do
  let(:instance) { described_class.new }

  it { should respond_to(:expire_time) }
  it { should respond_to(:id_prefix) }

  its(:id) { should match %r{\A\w{256}} }

  describe '#save' do
    it 'should raise an error' do
      expect{ subject.save }.to raise_error NotImplementedError
    end
  end

  describe '#destroy' do
    subject { instance.destroy }

    it 'should delete the key' do
      RedisStore.should_receive(:del).with( instance.id )

      subject
    end
  end

end

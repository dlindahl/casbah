describe Casbah::Service do
  subject { described_class }

  it { should respond_to :registry }
  it { should respond_to :registry= }

  describe '.registered?' do
    before { described_class.should_receive(:registered?).with(123) }

    it 'should delegate to the registry' do
      described_class.registered? 123
    end
  end

  describe '.register' do
    before { described_class.should_receive(:register).with({ url:'http://example.org' }) }

    it 'should delegate to the registry' do
      described_class.register url:'http://example.org'
    end
  end
end

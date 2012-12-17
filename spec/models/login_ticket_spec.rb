describe LoginTicket do
  let(:id) { 'LT-123' }

  let(:instance) { described_class.new( id:id) }

  its(:id_prefix) { should == 'LT-' }

  describe '#save' do
    subject { instance.save }

    context 'with a valid ticket' do
      it 'should save the ticket' do
        subject

        redis.get( id ).should eq '1'
      end
    end

    context 'with an invalid ticket' do
      let(:instance) { described_class.new }

      before { Casbah.stub(:generate_id).and_return nil }

      it 'should not save the ticket' do
        subject

        redis.keys('*').should be_empty
      end
    end
  end

  describe '#verify!' do
    subject { instance.verify! }

    context 'with a known LoginTicket' do
      before { instance.save }

      it { should be_true }

      it 'must invalidate the ticket' do
        instance.should_receive(:destroy)

        subject
      end
    end

    context 'with an unknown LoginTicket' do
      it { should be_false }

      it 'must invalidate the ticket' do
        instance.should_receive(:destroy)

        subject
      end
    end
  end

end

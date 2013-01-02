describe 'Casbah.config' do

  subject { Casbah.config }

  describe '#warden' do
    subject { Casbah.config.warden }

    it { should be_a Proc }
  end

  describe '#single_sign_out' do
    subject { Casbah.config.single_sign_out }

    it { should be_false }
  end

  describe '#authentication_filter' do
    subject { Casbah.config.authentication_filter }

    it { should == :require_login }
  end

  describe Casbah::ConfigurationConcern do
    let(:klass) do
      Class.new
    end

    before do
      stub_const 'MyConfig', klass
      MyConfig.extend described_class
    end

    describe '#service_options' do
      subject { MyConfig.service_options }

      it { should be_a Hash }
    end

    describe '#service_store' do
      subject { MyConfig.service_store }

      context 'with arguments' do
        context 'for a predefined Casbah service' do
          before { MyConfig.service_store :abstract_store, { foo:123 } }

          it { should == Casbah::Service::AbstractStore }

          it 'should set options' do
            MyConfig.service_options.should include( foo:123 )
          end
        end

        context 'for an abritrary class' do
          before do
            stub_const 'MyStore', Class.new

            MyConfig.service_store MyStore
          end

          it { should == MyStore }
        end
      end

      context 'without arguments' do
        it 'should have a default' do
          subject.should == Casbah::Service::MemoryStore
        end
      end
    end

    describe '#service_model' do
      subject { MyConfig.service_model }

      context 'with arguments' do
        context 'for a predefined Casbah model' do
          before { MyConfig.service_model :single_sign_out, { bar:456 } }

          it { should == Casbah::Service::SingleSignOut }

          it 'should set options' do
            MyConfig.service_options.should include( bar:456 )
          end
        end

        context 'for an abritrary class' do
          before do
            stub_const 'MyModel', Class.new

            MyConfig.service_model MyModel
          end

          it { should == MyModel }
        end
      end

      context 'without arguments' do
        it 'should have a default' do
          subject.should == Casbah::Service::Base
        end
      end
    end
  end
end
describe LoginController do

  subject { response }

  describe 'GET login' do
    before { get :index }

    it { should be_ok }
  end

end

describe '/cas/login routing' do

  it 'routes GET /cas/login to login#index' do
    expect( get:'/cas/login' ).to route_to controller: 'login', action: 'index'
  end

end

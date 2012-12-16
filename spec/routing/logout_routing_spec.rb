describe '/cas/logout routing' do

  it 'routes GET /cas/logout to logout#index' do
    expect( get:'/cas/logout' ).to route_to controller: 'logout', action: 'index'
  end

end

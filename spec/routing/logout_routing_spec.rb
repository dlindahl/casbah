describe '/logout routing' do

  it 'routes GET /logout to logout#index' do
    expect( get:'/logout' ).to route_to controller: 'logout', action: 'index'
  end

end

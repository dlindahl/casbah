describe '/login routing' do

  it 'routes GET /login to login#index' do
    expect( get:'/login' ).to route_to controller: 'login', action: 'index'
  end

  it 'routes POST /login to login#create' do
    expect( post:'/login' ).to route_to controller: 'login', action: 'create'
  end
end

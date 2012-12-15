describe '/login routing' do

  it 'routes /login to login#index' do
    expect( get:'/login' ).to route_to controller: 'login', action: 'index'
  end

end

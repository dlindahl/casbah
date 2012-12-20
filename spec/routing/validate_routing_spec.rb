describe '/validate routing' do

  it 'routes GET /validate to validate#index' do
    expect( get:'/validate' ).to route_to controller: 'validate', action: 'index'
  end

end

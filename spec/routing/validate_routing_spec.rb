describe '/cas/validate routing' do

  it 'routes GET /cas/validate to validate#index' do
    expect( get:'/cas/validate' ).to route_to controller: 'validate', action: 'index'
  end

end

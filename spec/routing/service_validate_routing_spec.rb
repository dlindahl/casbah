describe '/cas/serviceValidate routing' do

  it 'routes GET /cas/serviceValidate to validate#index' do
    expect( get:'/cas/serviceValidate' ).to route_to controller: 'service_validate', action: 'index'
  end

end

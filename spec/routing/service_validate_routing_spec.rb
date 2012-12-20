describe '/serviceValidate routing' do

  it 'routes GET /serviceValidate to validate#index' do
    expect( get:'/serviceValidate' ).to route_to controller: 'service_validate', action: 'index'
  end

end

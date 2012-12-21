require 'warden'

module Casbah
  class Engine < ::Rails::Engine

    initializer 'casbah.configure_warden' do |app|
      app.config.middleware.use Warden::Manager do |manager|
        manager.failure_app = LoginController.action( :authentication_failed )

        Casbah.config.warden.call manager
      end
    end

    initializer 'casbah.initialize_service_registry' do |app|
      store = Casbah.config.service_store

      if store
        opts  = Casbah.config.service_options
        model = Casbah.config.service_model

        raise SSOConfigError if Casbah.config.single_sign_out && !Casbah::Service::SingleSignOut.subclasses.include?(model)

        Casbah::Service.registry = store.new( model, opts )
      end
    end

  end
end

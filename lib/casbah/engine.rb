require 'warden'

module Casbah
  class Engine < ::Rails::Engine

    initializer 'casbah.configure_warden' do |app|
      app.config.middleware.use Warden::Manager do |manager|
        manager.failure_app = LoginController.action( :authentication_failed )

        Casbah.config.warden.call manager
      end
    end

  end
end

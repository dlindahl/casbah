require 'warden'

module Casbah
  class Engine < ::Rails::Engine

    initializer 'casbah.configure_warden' do |app|
      app.config.middleware.use Warden::Manager do |manager|
        manager.failure_app = app # TODO: Can't figure out why this is a required config option

        Casbah.config.warden.call manager
      end
    end

  end
end

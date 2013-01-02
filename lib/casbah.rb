require 'securerandom'
require 'active_support/configurable'

require 'casbah/errors'
require 'casbah/configuration_concern'
require 'casbah/engine'

module Casbah
  include ActiveSupport::Configurable

  config_accessor :warden
  config_accessor :single_sign_out
  config_accessor :authentication_filter

  def self.generate_id( prefix )
    [ prefix, SecureRandom.hex(128) ].join ''
  end
end

Casbah.config.extend Casbah::ConfigurationConcern

Casbah.config.warden = Proc.new { }
Casbah.config.single_sign_out = false

# The default value is derived from the Rails guide on filters
# http://guides.rubyonrails.org/action_controller_overview.html
Casbah.config.authentication_filter = :require_login

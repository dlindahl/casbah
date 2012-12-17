require 'securerandom'
require 'active_support/configurable'

require 'casbah/engine'

module Casbah
  include ActiveSupport::Configurable

  config_accessor :warden

  def self.generate_id( prefix )
    [ prefix, SecureRandom.hex(128) ].join ''
  end
end

Casbah.config.warden = Proc.new { }
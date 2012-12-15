require 'securerandom'

require 'casbah/engine'

module Casbah
  def self.generate_id( prefix )
    [ prefix, SecureRandom.hex(128) ].join ''
  end
end

require 'casbah/service/yaml_store'
require 'casbah/service/redis_store'
require 'casbah/service/base'
require 'casbah/service/single_sign_out'

module Casbah
  module Service

    def self.registry
      @registry
    end

    def self.registry=( store )
      @registry = store
    end

    def self.registered?( id )
      @registry.registered?( id )
    end

  end
end

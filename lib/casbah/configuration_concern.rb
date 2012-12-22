require 'casbah/service'

module Casbah
  module ConfigurationConcern
    extend ActiveSupport::Concern

    def self.extended( klass )
      klass.instance_variable_set '@service_store',   :memory_store
      klass.instance_variable_set '@service_model',   :base
      klass.instance_variable_set '@service_options', {}
    end

    def service_options
      @service_options
    end

    def service_store( *args )
      if args.empty?
        case @service_store
        when Symbol
          Casbah::Service.const_get @service_store.to_s.camelize
        else
          @service_store
        end
      else
        @service_store   = args.shift
        (@service_options||={}).merge!( args.shift || {} )
      end
    end

    def service_model( *args )
      if args.empty?
        case @service_model
        when Symbol
          Casbah::Service.const_get @service_model.to_s.camelize
        else
          @service_model
        end
      else
        @service_model = args.shift
        (@service_options||={}).merge!( args.shift || {} )
      end
    end

  end
end
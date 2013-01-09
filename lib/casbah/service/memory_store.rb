require 'casbah/service/abstract_store'

module Casbah
  module Service
    class MemoryStore < AbstractStore

      def fetch( id )
        service = services.find{ |s| s.id == id }

        raise Casbah::ServiceNotFoundError unless service

        deserialize( service ).tap do |s|
          s.instance_variable_set '@new_record', false
        end
      end

      def register( service )
        instance = deserialize( service )

        unless services.collect(&:id).include? instance.id
          services << serialize( instance )
        end

        service.tap{ |s| s.instance_variable_set( '@new_record', false ) }
      end

      def delete( service )
        services.reject!{ |s| s.id == service.id }

        service.tap{ |s| s.instance_variable_set( '@destroyed', true ) }
      end

      # TODO: Even though the values are already deserialized by the YAML lib,
      # should this go through #deserialize anyway?
      def services
        @services ||= []
      end

      def clear!
        @services = nil
      end

    end
  end
end

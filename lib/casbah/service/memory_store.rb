require 'casbah/service/abstract_store'

module Casbah
  module Service
    class MemoryStore < AbstractStore

      def fetch( id )
        deserialize services.find{ |s| s.id == id }
      end

      def register( service )
        instance = deserialize( service )

        unless services.collect(&:id).include? instance.id
          services << serialize( instance )
        end
      end

      def delete( id )
        service = fetch( id )

        services.reject!{ |s| s.id == id }

        service
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

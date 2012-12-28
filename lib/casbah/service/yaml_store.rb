require 'casbah/service/abstract_store'

module Casbah
  module Service
    class YamlStore < AbstractStore

      def initialize(*)
        super

        @options[:path] ||= Rails.root.join('config', 'registered_services.yml')
      end

      def fetch( id )
        service = services.find{ |s| s.id == id }

        raise Casbah::ServiceNotFoundError unless service

        deserialize service
      end

      def register( service )
        instance = deserialize( service )

        collection = services

        unless collection.collect(&:id).include? instance.id
          collection << serialize( instance )
        end

        write collection
      end

      def delete( id )
        service = fetch( id )

        write services.reject{ |s| s.id == id }

        service
      end

      # TODO: Even though the values are already deserialized by the YAML lib,
      # should this go through #deserialize anyway?
      def services
        (YAML.load_file( @options[:path] )||[]) rescue []
      end

      def clear!
        write []
      end

    private

      def write( collection )
        File.open( @options[:path], 'w' ) do |f|
          YAML.dump collection, f
        end

        collection
      end

    end
  end
end

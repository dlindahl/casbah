module Casbah
  module Service
    class Base
      include ActiveModel::Validations
      include ActiveModel::Serializers::JSON

      attr_accessor :id, :url

      validates_presence_of :url, allow_blank:false

      def initialize( params = {} )
        params.each do |k, v|
          if respond_to? "#{k}="
            self.send "#{k}=", v
          else
            instance_variable_set "@#{k}", v
          end
        end
      end

      def id
        "service.#{url}"
      end

      def to_s
        id
      end

      def url=( value )
        uri = Addressable::URI.parse( value ) if value.is_a? String

        @url = uri.origin if uri
      end

      def attributes
        {
          'id'  => id,
          'url' => url
        }
      end

      def destroy
        Casbah::Service.registry.delete( id )
      end

      def register
        if valid?
          Casbah::Service.registry.register( self )
        end
      end

    end
  end
end

module Casbah
  module Service
    class Base
      include ActiveModel::Validations
      include ActiveModel::Serializers::JSON

      attr_accessor :id, :url

      validates_presence_of :url, allow_blank:false

      def initialize( params = {} )
        self.url = params[:url]
      end

      def id
        "service.#{url}"
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

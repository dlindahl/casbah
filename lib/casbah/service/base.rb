module Casbah
  module Service
    class Base
      include ActiveModel::Validations
      include ActiveModel::Conversion
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

      def new_record?
        @new_record
      end

      def destroyed?
        @destroyed
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def url=( value )
        uri = Addressable::URI.parse( value ) if value.is_a?( String )

        @url = uri.origin if uri && uri.origin != 'null'
      end

      def attributes
        {
          'id'  => id,
          'url' => url
        }
      end

      def destroy
        Casbah::Service.registry.delete( self )
      end

      def register
        if valid?
          Casbah::Service.registry.register( self )
        end
      end

    end
  end
end

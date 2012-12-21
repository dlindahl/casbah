module Casbah
  module Service
    class AbstractStore

      def initialize( model, options = {} )
        @model, @options = model, options
      end

      def fetch(*)
        raise NotImplementedError, "#{self.class} has not implemented #fetch"
      end

      def register(*)
        raise NotImplementedError, "#{self.class} has not implemented #register"
      end

      def delete(*)
        raise NotImplementedError, "#{self.class} has not implemented #delete"
      end

      def services
        raise NotImplementedError, "#{self.class} has not implemented #services"
      end

      def registered?( id )
        not fetch( id ).nil?
      end

      def clear!
        raise NotImplementedError, "#{self.class} has not implemented #clear!"
      end

      def serialize( service )
        service
      end

      def deserialize( obj )
        service = obj.is_a?(@model) ? obj : @model.new( obj )

        raise Casbah::Service::Base::ValidationError, service.errors.full_messages unless service.valid?

        service
      end

    end
  end
end
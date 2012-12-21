module Casbah
  module Service
    class SingleSignOut < Base
      attr_accessor :logout_path

      validates_presence_of :logout_path, allow_blank:false

      def initialize( params = {} )
        super

        @logout_path = params[:logout_path]
      end

      def logout_path
        @logout_path || Casbah.config.service_options[:logout_path]
      end

      def logout_url
        url + logout_path
      end

      def attributes
        super.merge({
          'logout_path' => logout_path
        })
      end
    end
  end
end
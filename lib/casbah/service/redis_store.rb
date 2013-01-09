require 'casbah/service/abstract_store'

module Casbah
  module Service
    class RedisStore < AbstractStore

      def fetch( id )
        raise ServiceNotFoundError unless redis.exists( id )

        obj = redis.hgetall( id )

        deserialize( obj ).tap do |s|
          s.instance_variable_set '@new_record', false
        end
      end

      def register( obj )
        service = deserialize( obj )

        redis.pipelined do
          serialize( service ).each do |k, v|
            redis.hset service.id, k.to_sym, v
          end
        end

        service.tap{ |s| s.instance_variable_set( '@new_record', false ) }
      end

      def delete( service )
        redis.del service.id

        service.tap{ |s| s.instance_variable_set( '@destroyed', true ) }
      end

      def services
        redis.keys('service.*').map{|id| fetch(id) }
      end

      def registered?( id )
        redis.exists id
      end

      def clear!
        redis.keys('service.*').each do |k|
          redis.pipelined do
            redis.del k
          end
        end
      end

      def serialize( service )
        service.serializable_hash.tap do |attrs|
          attrs.delete 'id'
        end
      end

    private

      def redis
        Casbah.config.redis
      end

    end
  end
end

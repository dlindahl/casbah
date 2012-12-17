class Ticket
  include ActiveModel::Validations

  class_attribute :expire_time
  class_attribute :id_prefix

  attr_reader :id

  validates_presence_of :id, allow_blank:false

  def initialize( params = {} )
    @id = params[:id] || Casbah.generate_id( id_prefix )
  end

  def save
    raise NotImplementedError, '#save is not implemented'
  end

  def destroy
    redis.del id
  end

  class << self
    def redis
      Casbah.config.redis
    end
  end

private

  def redis
    self.class.redis
  end

end

Ticket.expire_time = 5.minutes

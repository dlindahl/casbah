class Ticket
  include ActiveModel::Validations

  @@expire_time = 5.minutes
  cattr_accessor :expire_time

  @@id_prefix = 'ST-'
  cattr_accessor :id_prefix

  attr_reader :id

  validates_presence_of :id, allow_blank:false

  def initialize( params = {} )
    @id = params[:id] || Casbah.generate_id( id_prefix )
  end

  def save
    raise NotImplementedError, '#save is not implemented'
  end

  def destroy
    RedisStore.del id
  end

end

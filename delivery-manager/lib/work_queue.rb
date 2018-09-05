require 'bunny'
require 'base64'
require 'pry'
require 'json'

# queue to
class WorkQueue
  def initialize(name)
    @connection = Config.active.amqp_connection
    @ch = @connection.create_channel
		n = 1
		@ch.prefetch(n)
		@queue = @ch.queue(name,:persistent => true, :auto_delete => false, :durable => true, :exclusive => false)

  end

  def publish(data)
	  unless data['image'].nil?
			data[image] = Base64.encode64(data['image'])
	  end
	  puts "   Storing #{data}"

	  json = data.to_json
	  # msg = Base64.encode64(data)

	  @ch.default_exchange.publish(json, routing_key: @queue.name, :persistent => true, :auto_delete => false,
	                               :durable => true, :exclusive => false)
  end

  def queue
	  @queue
  end

  def ch
    @ch
  end

  def close
	  @ch.close
  end

  def ack(msg)
	  @ch.act(msg)
  end

  def nack(msg)
	  @ch.nack(msg)
  end
  # def self.topic_exchange
  #   @topic_exchange ||= self.channel.topic('ihids')
  # end



end

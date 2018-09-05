require 'bunny'
require 'base64'
require 'pry'


class InQueue

  def initialize( name)
    @config = Config.active
    connection = @config.amqp_connection

		@ch  = connection.create_channel
		n = 1
    @ch.prefetch(n)
    @queue = @ch.queue(name, :persistent => true, :auto_delete => false, 
        :durable => true, :exclusive => false)

		#@key = "ihids.archive.#{mode}"
	end

	def publish(data)
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
		@ch.ack(msg)
	end
end
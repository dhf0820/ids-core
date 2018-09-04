require 'bunny'
require 'base64'
require 'pry'


class DeliverQueue

	def initialize(connection,queue_name)
		@ch   = connection.create_channel
		@queue = @ch.queue(queue_name) #"ids.deliver")

		#@key = "ihids.archive.#{mode}"
	end

	def publish(data, image)
		puts "   Storing #{data}"
		data['image'] =  Base64.encode64(image)

		json = data.to_json

		# msg = Base64.encode64(data)

		@ch.default_exchange.publish(json, routing_key: @queue.name, :persistent => true, :auto_delete => false,
		                             :durable => true, :exclusive => false)
	end
end


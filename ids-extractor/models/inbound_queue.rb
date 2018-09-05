
require 'bunny'
require 'base64'
require 'pry'

#module IDSReader
	class InboundQueue

		def initialize(connection, queue_name)
			#$log.info "INboundQueue name : #{queue_name}"
			#STDERR.puts "InBound queue name : #{queue_name}"
			#puts "Print queue name #{queue_name}"
			@conn = connection
			@ch   = connection.create_channel
			n = 1
			@ch.prefetch(n)
			@queue = @ch.queue(queue_name, :persistent => true, durable: true, auto_delete: false, exclusive: false)

			#@key = "ihids.archive.#{mode}"
		end

		def publish(data, image)
			#puts "   Storing #{data}"

			data['image'] =  Base64.encode64(image)

			json = data.to_json

			# msg = Base64.encode64(data)

			@ch.default_exchange.publish(json, routing_key: @queue.name, :persistent => true, :auto_delete => false,
			                             :durable => true, :exclusive => false)
		end

		def queue
			@queue
		end

		def channel
			@ch
		end

		def close_channel
			@ch.close
		end

		def ack(msg)
			@ch.ack(msg)
		end

		def nack(msg)
			@ch.nack(msg)
		end
		# def self.topic_exchange
		#   @topic_exchange ||= self.channel.topic('ihids')
		# end
		def stop
			@ch.close
			@conn.close
		end
	end
#end
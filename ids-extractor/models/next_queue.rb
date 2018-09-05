
require 'bunny'
require 'base64'
require 'pry'

#module IDSReader
  class NextQueue

    def initialize(connection, queue_name)
      @ch   = connection.create_channel
      @queue = @ch.queue("#{queue_name}")

    end

    def publish(data, image)
      $log.debug "   Storing #{data}"
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

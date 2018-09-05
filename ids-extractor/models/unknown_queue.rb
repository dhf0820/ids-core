require 'bunny'
require 'base64'
require 'pry'

#module IDSReader
  class UnknownQueue

    def initialize(connection, processor_name, mode)
      ch   = connection.create_channel
      @processor_name = processor_name
      @xchange = ch.topic(Config.current(:unknown_queue))
      @key = "#{Config.current(:unknown_queue)}"
    end

    def publish(image)

      data = {}
      data['processor_name'] = @processor_name
      data['image'] =  Base64.encode64(image)
      json = data.to_json
      $log.info "Unknown document on #{@processor_name}"

      @xchange.publish(json, routing_key: @key, :persistent => true)
    end
  end
#end
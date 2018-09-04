

class VsLog

	def initialize(connection)

		@connection = connection
		@app_name = $app_env.app_name

		STDERR.puts "@@@###  #{@app_name} - Worker Queue Bunny Connection: #{@connection.inspect}"
		@ch = @connection.create_channel
		#@ch.topic('ids_topic_logs')

		@log_key = $app_env.log_key
		@logx = topic_exchange('ids_logs')
	end

	# def initialize(app_name = 'anonymous')
	# 	@@app_name = app_name
	# 	@@wq = WorkerQueue.new
	#
	# 	@@logx = @wq.topic_exchange("topic_logs")
	# 	# severity = ARGV.shift || "anonymous.info"
	# 	# msg      = ARGV.empty? ? "Hello World!" : ARGV.join(" ")
	# end


	# def self.start
	# 	@@app_name = ENV['LOG_BASE']
	# 	@@wq = WorkerQueue.new('VsLog')
	#
	# 	@@logx = @@wq.topic_exchange('topic_logs')
	# end

	# def entry(severity, message)
	# 	@@logx.publish(" #{message}", :routing_key => "#{@@app _name}.#{severity}")
	# end

	def info(message)
		STDERR.puts "INFO: #{message}"
		@logx.publish(" #{message}", :routing_key => "#{@log_key}.info")
	end

	def debug( message)
		#STDERR.puts "Routing Key: #{@log_key}"
		STDERR.puts "DEBUG: #{message}"
		@logx.publish(" #{message}", :routing_key => "#{@log_key}.debug")
	end

	# def self.debug1(component, message)
	# 	self.start if (!(defined? @@logx) || (@@logx.blank?))
	# 	STDERR.puts "DEBUG: #{message}"
	# 	@@logx.publish(" #{message}", :routing_key => "#{@@app_name}.#{component}.debug")
	# end

	def fatal( message)
		STDERR.puts "FATAL: #{message}"
		@logx.publish(" #{message}", :routing_key => "#{@log_key}.fatal")
	end

	def warn( message)
		STDERR.puts ("Warn: #{message}")
		@logx.publish(" #{message}", :routing_key => "#{@log_key}.warn")
	end

	def close
		#return if (!(defined? @logx) || (@logx.blank?))
		@ch.close
		@ch =  nil
	end

  private
	def default_exchange
		@ch.exchange('')
	end

	def direct_exchange(name)
		@ch.exchange(name)
	end

	def topic_exchange(topic_name)
		@ch.topic(topic_name)
	end

end
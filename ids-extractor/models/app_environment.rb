require './models/environment'

require './models/ids_error'

class AppEnvironment  < Environment
	@@app_env = nil
	@@sys_env = nil

	# def self.env
	# 	if @@app_env.nil?
	# 		raise IdsError.new 'Application environemnt is not set up'
	# 	end
	#
	# 	@@app_env
	# end


	def self.for_process(customer, proc)

		@@sys_env = CustomerEnvironment.for_customer(customer)
		if @@sys_env.nil?
			raise IdsError.new "Customer environment for #{customer} not setup for process #{proc}"
		end
		#puts "sys_env: #{@@sys_env.inspect}"
    @@app_env = AppEnvironment.where(customer: @@sys_env.customer, process: proc).first

    @@app_env
	end

	def self.sys
		@@sys_env
	end

	def sys
		@@sys_env
  end
  
  def sys_environment
		@@sys_env.environment
	end

	def env(key)
		environment[key.to_sym]
	end

	# def out_queue_name=(value)
	# 	self.environment[:out_queue] = value
	# end

  # def out_queue_name
  #   @proc.out_queue_name
	# 	#self.environment[:out_queue]
	# end

	# def in_queue_name=(value)
	# 	self.environment[:in_queue] =  value
	# end

  # def in_queue_name
  #   @proc.in_queue_name
	# 	#self.environment[:in_queue]
	# end

	# def error_queue_name=(value)
	# 	self.environment[:error_queue] =  value
	# end

  # def error_queue_name
  #   @proc.error_queue_name
	# 	#self.environment[:error_queue]
	# end

	# def app_name=(value)
	# 	self.environment[:app_name] = value
	# end

  # def app_name
  #   @proc.app_name
	# 	#self.environment[:app_name]
	# end

	# def log_key=(value)
	# 	self.environment[:log_key] = value
	# end

  # def log_key
  #   @proc.log_key
	# 	#self.environment[:log_key]
	# end

	# def log_topic=(value)
	# 	self.environment[:log_topic] = value
	# end

  # def log_topic
  #   @proc.log_topic
	# 	#self.environment[:log_topic]
	# end

	# def in_queue=(queue)
	# 	@in_queue = queue
	# end

	# def in_queue
	# 	@in_queue
	# end

	# def out_queue=(queue)
	# 	@out_queue = queue
	# end

	# def out_queue
	# 	@out_queue
	# end

	# def err_queue=(queue)
	# 	@error_queue = queue
	# end

	# def err_queue
	# 	@error_queue
	# end

	def amqp
		if @amqp.nil?

			sys_env = CustomerEnvironment.env #for_customer(self.customer)
			if sys_env.nil?
				raise IdsError.new("#{self.customer} is not setu up")
			end
			@amqp = sys_env.amqp
		end
		@amqp
	end

	def remote_url
		@@sys_env.remote_url
		# if @remote_url.nil?
		# 	@remote_url = sys_env.remote
		# 	sys_env = CustomerEnvironment.env #for_customer(self.customer)
		# 	if sys_env.nil?
		# 		raise IdsError.new("#{self.customer} is not setu up")
		# 	end
		# 	@remote_url = sys_env.remote_url
		# end
		# @remote_url
	end

	def remote_token
		@@sys_env.remote_token
		# if @remote_token.nil?
		#
		# 	sys_env = CustomerEnvironment.env #for_customer(self.customer)
		# 	if sys_env.nil?
		# 		raise IdsError.new("#{self.customer} is not setu up")
		# 	end
		# 	@remote_token = remote_token
		# end
		# @remote_token
	end


	def amqp_connection=(connection)
		@rabbit_connection = connection
	end

	def amqp_connection
		@rabbit_connection
	end

	def amqp_name=(name)
		@rabbit_name = name
	end

	def amqp_name
		@rabbit_name
	end

	# def descriptor_keys
	# 	self.environment[:descriptor_keys]
	# end

	def save
		super
	end

  def method_missing(m, *args, &block)
    puts "There's no method called #{m} -  args: #{args}  here -- Looking in Environment hash"

    @@app_env.environment[m.to_sym]
  end

end
require './models/environment'
require './models/ids_error'

class AppEnvironment  < Environment
	@@app_env = nil


	def self.env
		if @@app_env.nil?
			raise IdsError.new 'Application environemnt is not set up'
		end
		@@app_env
	end


	def self.for_process(proc)
		sys_env = CustomerEnvironment.env
		if sys_env.nil?
			raise IdsError.new "Customer environment not setup for process #{proc}"
		end
		puts "sys_env: #{sys_env.inspect}"
		@@app_env = AppEnvironment.where(customer: sys_env.customer, process: proc).first
	end

	def out_queue=(value)
		self.environment[:out_queue] = value
	end

	def out_queue
		self.environment[:out_queue]
	end

	def in_queue=(value)
		self.environment[:in_queue] =  value
	end

	def in_queue
		self.environment[:in_queue]
	end

	def app_name=(value)
		self.environment[:app_name] = value
	end

	def app_name
		self.environment[:app_name]
	end

	def log_key=(value)
		self.environment[:log_key] = value
	end

	def log_key
		self.environment[:log_key]
	end

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

	def save
		super
	end

end
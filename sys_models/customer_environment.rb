require '../sys_models/environment'
require '../sys_models/ids_error'

class CustomerEnvironment < Environment

    @@cust_env = nil

	def self.for_customer(cust)
		@@cust_env = CustomerEnvironment.where(process: 'system', customer: cust).first

	end

    def self.cust_env
		@@cust_env
    end

	def self.env
		if @@cust_env.nil?
			raise IdsError.new("Customer #{self.customer} is not set up")
		end
		@@cust_env
	end

	def amqp=(value)
		self.environment[:amqp] = value
	end

	def amqp
		self.environment[:amqp]
	end

	def remote_url= (value)
		self.environment[:remote_url] = value
	end

	def remote_url
		self.environment[:remote_url]
	end

	def remote_token=(value)
		self.environment[:remote_token] = value
	end

	def remote_token
		self.environment[:remote_token]
	end

	def remote_user=(value)
		self.environment[:remote_user] = value
	end

	def remote_user
		self.environment[:remote_user]
	end

	def remote_password=(value)
		self.environment[:remote_password] = value
	end

	def remote_password
		self.environment[:remote_password]
	end
end


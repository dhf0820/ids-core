require '../sys_models/delivery_device'

class NoDelivery < DeliveryDevice
	@@none = nil

	def initialize
		none = NoDelivery.first
		if none.nil?
			super
			self.name = 'None'
			self.description = 'No delivery'
			self.status = {}
			self.status[:state] = 'Active'
			self.status[:reason] = "System Device"
			self.save
			@@none = self
		else
			raise IdsError.new("NoDelivery device already exists")
		end
	end

	def self.default

		@@none = NoDelivery.first
		if @@none.nil?
			raise IdsError.new "NoDeliveryClass is not setup"
		end
		@@none
	end

	def extend()
		return true
	end

	def queue(clin_doc, recipient, patient)
		puts "Log no Delivery for #{recipient[:name]}"
		nil
	end

end
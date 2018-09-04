
require './models/delivery_class'
require './models/no_delivery'
require './models/ids_error'

class NoDeliveryClass < DeliveryClass

	@@none = nil


	def initialize()
		@@none = NoDeliveryClass.first
		if @@none
			raise IdsError.new('No Delivery class is already set up. Use it.')
		end
		super
		self.name = 'None'
		self.description = 'No delivery this type/class of documents'

		self[:validation_required] = false
		self.save
		@@none = self

	end

	def self.default
		@@none = NoDeliveryClass.first #where(name: 'None').first
		if @@none.nil?
			@@none = NoDeliveryClass.new()
			@@none.save

		end
		@@none
	end

	def self.default_device
		self.default
		@@none_device = NoDelivery.default
		#self.default.devices[0]
		#@@none_device
	end

	def extend()
		self.name = 'None'
		self.description = 'No delivery'
		self.status = {}
		self.status[:state] = "Active"
		self.status[:reason] = "Initial System"
		#self.delivery_details = {}    #what delivery for Mail require.
		nd = NoDelivery.new
		nd.save
		@@none_device = nd
		self.add_device(nd)
		@@none_device = nd
	end

end

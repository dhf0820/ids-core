require '../sys_models/delivery_device'
require '../sys_models/delivery_request'
require '../sys_models/ids_error'

class MailDelivery < DeliveryDevice

	def initialize
		md = MailDelivery.first
		if md.nil?
			super
			name = 'Mail delivery'
			self.save
		else
			raise IdsError.new("Default Mail Delivery Device already exists, use it.")
		end
		# if MailDelivery.count > 0
		# 	binding.pry
		# 	raise IdsError("Default Mail Delivery Device already exists, use it.")
		# end
		# super
	end

	def self.default
			device = MailDelivery.first
		if device.nil?
			raise IdsError.new "Missing Default Mail Device"
		end
		device
	end

	def extend()
		self.name = 'Mail'
		self.description = 'Daily mail delivery device'
		self.status = {}
		self.status[:state] = 'Active'
		self.status[:reason] = "System Device"
		self.write_attribute(:mail, {})
		true
	end


	def queue(clin_doc, recipient)
		delv_req = DeliveryRequest.new
		#delv_req.device_id = self.id
		#delv_req.device_class_id = self.delivery_class_id
		delv_req.device = self.summary
		delv_req.recipient = recipient
		delv_req.patient = clin_doc.patient
		delv_req.document = clin_doc.summary
		delv_req.queued_time = DateTime.now
		delv_req.save
		delv_req
	end
end



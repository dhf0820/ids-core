require '../sys_models/delivery_class'
require '../sys_models/ids_error'

class FaxClass < DeliveryClass
	@@fax = nil

	def initialize()
		@@fax = FaxClass.first
		if @@fax
			raise IdsError.new('FAX delivery class is already set up. Use it.')
		end
		super
		@@fax = self
		self.name = 'FAX'
		self.description = 'Delivery using the FAX cloud services'

		self[:validation_required] = true
		#self.validation_requred = true
		#super(name: 'EFAX', description: 'Delivery using the EFAX cloud services')
	end

	def self.default
		@@fax = FaxClass.first
		if @@fax.nil?
			puts "Create FAX Delivery Class"
			@@fax = FaxClass.new()
			@@fax.save
		end
		@@fax
	end

	def extend()
		self.device_type = 'FAX'
	end

	def queue(clin_doc, recipient, device)
		delv_req = DeliveryRequest.new
		delv_req.device = self.summary
		delv_req.device_id = device.id.to_s
		delv_req.device_class_id = self.id
		delv_req.recipient = recipient
		delv_req.patient = clin_doc.patient
		delv_req.document = clin_doc.summary
		delv_req.queued_time = DateTime.now
		delv_req.command = self.fax_number
		delv_req.save
		delv_req
	end
end
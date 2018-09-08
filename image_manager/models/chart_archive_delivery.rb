require '../sys_models/delivery_device'
require './models/chart_archive_class'

class ChartArchiveDelivery < DeliveryDevice

	def initialize
		cad = ChartArchiveDelivery.first
		if cad.nil?
			super
      name = 'ChartArchive'
      self.name = 'ChartArchive'
      self.description = 'Delivery to ChartArchive'
		else
			raise IdsError.new("Default ChartArchiveDevice already exists, use it.")
		end
	end

  def extend

    self.name = 'ChartArchive'
    self.description = 'Delivery to ChartArchive'
    self.save
  end

  def self.default
    ChartArchiveClass.default_device
		# 	device = ChartArchiveDelivery.first
		# if device.nil?
		# 	raise IdsError.new "Missing ChartArchiveDevice"
		# end
		# device
  end
  
  def queue(clin_doc, recipient)
		delv_req = DeliveryRequest.new
		delv_req.device = self.summary
		delv_req.device_id = self.id.to_s
    delv_req.device_class_id = self.delivery_class_id

		delv_req.recipient = recipient.summary
		delv_req.patient = clin_doc.patient
		delv_req.document = clin_doc.summary
		delv_req.queued_time = DateTime.now
		delv_req.save
		delv_req
  end
end

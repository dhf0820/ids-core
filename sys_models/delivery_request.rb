require '../sys_models/delivery_class'
require '../sys_models/delivery_device'


class DeliveryRequest
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic

	#field   :id,                    type: String
	field   :device_id,         type: String
	field   :device_class_id,   type: String
	field   :command,           type: String
	field   :tracking_number,   type: String
	field   :delivery_job_id,   type: String
	field   :device,            type: Hash, default: {}
	field   :priority,          type: Hash, default: {}
	field   :status,            type: Hash, default: {}
	field   :meta,              type: Hash, default: {}
	field   :document,          type: Hash, default: {}
	field   :recipient,         type: Hash, default: {}
	field   :patient,           type: Hash, default: {}
	field   :queued_time,       type: DateTime
	field   :updated,           type: Hash, default:  {}
	field   :created,           type: Hash, default: {}
  field   :internal_image,    type: String

	def self.request_delivery(dp, cdoc)
		#puts "DeliveryRequest#request_delivery: #{dp}"
		device = DeliveryDevice.find dp.device[:device_id]
		device.queue(cdoc, dp.owner)  #  Really do not need owner as device belongs to the owner
	end

	def self.queue_default(owner, cdoc)
		#puts "DeliveryRequest#queue_default: #{cdoc.summary}"
		if owner[:primary_device]
			primary_device = owner[:primary_device][:device_id]
		else
			primary_device == nil?
		end
		if primary_device.nil?
			device = MailDeliveryClass.default_device
		else
			device = DeliveryDevice.find(owner[:primary_device][:device_id])
		end
		device.queue(cdoc, owner)  #  Really do not need owner as device belongs to the owner
	end


end
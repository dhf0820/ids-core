require '../sys_models/updateable'


class DeliveryDevice
	require 'json'
	include Mongoid::Document
	include Updateable
	include Mongoid::Attributes::Dynamic

	field   :id,                    type: String
	field   :name,                  type: String
	field   :description,           type: String
	field   :format,                type: String
	field   :delivery_class_id,     type: String
	field   :delivery_class_name,   type: String
	field   :owner,                 type: Hash,     default: {}
	field   :status,                type: Hash,     default: {}
	field   :validation,            type: Hash,     default: {}
	field   :updated,               type: Hash,     default: {}
	field   :created,               type: Hash,     default: {}
	field   :queue_details,         type: Hash,     default: {}


	# def initialize()
	# 	super
	# 	self.extend(args)
	# 	return if args.nil?
	# 	self.name = args[:name]
	# 	self.description = args[:description]
	# 	self.format = args[:format] || 'PDF'
	# 	self.owner = args[:owner] || {}
	# 	self.status = args[:status] || {}
	# 	if args[:delv_class]
	# 		self.device_class=args[:delv_class]
	# 	end
	# end

	def entity=(value)
		self.owner = value.entity
	end

	def entity
		self.owner
	end

	def extend()
		raise IDSError.new("Extended must be defined.")
	end

	def device_class=(delv_class)
		delv_class.add_device(self)
		delv_class.save
	end

	def summary
		data = {}
		data[:device_id] = self.id.to_s
		data[:device_name] = self.name
		data[:class_id] = self.delivery_class_id.to_s
		data[:class_name] = self.delivery_class_name
		data
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

  # def save
  #   if self.new_record?
	# 		self.created = update_info(nil)
	# 	end
	# 	self.updated = update_info(nil)

  #  super
  # end
  
  # private
  # def update_info(user_id)
  #   data = {}
  #   data[:on] = DateTime.now
  #   unless user_id.nil?
  #     user = User.find user_id
  #     if user
  #       data[:user_id] = user.id
  #       data[:name] = user.full_name
  #     end
  #   end
	# 	data
	# end
end
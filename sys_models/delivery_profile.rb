require '../sys_models/updateable'

class DeliveryProfile
	require 'json'
	include Mongoid::Document
	include Updateable
	include Mongoid::Attributes::Dynamic

	#field   :id,                    type: String
	field   :owner,                 type: Hash, default: {}
	field   :delivery_context,      type: Array, default: []
	field   :doc_type,              type: Hash, default: {}
	field   :doc_class,             type: Hash, default: {}
	#field   :document,              type: Hash, default: {}
	field   :device,                type: Hash, default: {}
	field   :updated,               type: Hash, default: {}
	field   :created,               type: Hash, default: {}


	def self.create_type_profile(doc_type, delv_device, owner,  delivery_context)
		#self.remove_profile(owner, type_info, delv_device, delivery_context)
		dp = DeliveryProfile.new()
		dp.owner = owner.entity
		dp.delivery_context = delivery_context
		dp.doc_type = doc_type.summary #{ids_id: type_info[:ids_id], code: type_info[:code]}
		#dp.doc_class = {id: type_info[:class_id], code: type_info[:class_code]}
		dp.device = delv_device
		dp
	end
	#
	# def self.add_doc_type_profile(doc_type, delv_device, owner, delivery_context)
	# 	self.remove_profile(owner, doc_type, delv_device, delivery_context)
	# 	dp = DeliveryProfile.new()
	# 	dp.owner = owner.recipient  #{id: owner.id, name: owner.full_name, context: owner_context}
	# 	dp.delivery_context = delivery_context
	# 	dp.doc_type = {id: doc_type.id, code: doc_type.code, description: doc_type.description}
	# 	#dp.doc_class = doc_type.document_class
	# 	dp.device = delv_device
	# 	dp
	# end


	def self.create_class_profile(type_info, delv_device, owner, delivery_context)
		#self.remove_doc_class_profile_profile(owner, doc_type, delv_device, delivery_context)
		dp = DeliveryProfile.new()
		dp.owner = owner #{id: owner.id, name: owner.full_name, context: owner_context}
		dp.delivery_context = delivery_context
		# dp.doc_type = nil  #{id: doc_type.id, code: doc_type.code, description: doc_type.description}
		dp.doc_class = {ids_id: type_info[:class_id], code: type_info[:class_code]}
		dp.device = delv_device
		dp
	end

	def self.remove_profile(owner, type_info, delv_device, delivery_context)

	end


	def add_device(device)
		self.device = device
	end

	# def self.by_document(doc, owner, delivery_context)
	# 	DeliveryProfile.where('document.id' => doc[:id], 'owner.id' => owner[:id], delivery_context: delivery_context)
	# end

	def self.by_doc_type(type_info, owner) #, context)
		DeliveryProfile.where('doc_type.ids_id' => type_info[:ids_id], 'owner.id' => owner[:id]) #, delivery_context: {:$in =>context})
	end

	def self.by_doc_class(type_info, owner)  #, context)
		DeliveryProfile.where('doc_class.ids_id' => type_info[:class_id], 'owner.id' => owner[:id]) #, delivery_context: {:$in =>context})
	end

end
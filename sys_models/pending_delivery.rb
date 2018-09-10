require '../sys_models/delivery_class'
require '../sys_models/delivery_device'




class PendingDelivery
	require 'json'
	include Mongoid::Document
	include Updateable
#include Mongoid::Attributes::Dynamic

	field   :name,          type: String
	field   :clin_doc_id,   type: String
	field   :raw_name_id,   type: String
	field   :updated,       type: Hash,     default: {}
	field   :created,       type: Hash,     default: {}

	def self.by_raw_doc(raw_id, doc_id)
		PendingDelivery.where(raw_name_id: raw_id, clin_doc_id: doc_id).first
	end
end
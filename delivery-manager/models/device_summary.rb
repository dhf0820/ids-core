class DeviceSummary
	require 'json'
	include Mongoid::Document

	field   :id,            type: BSON::ObjectId
	field   :class_id,      type: BSON::ObjectId
	field   :name,          type: String
	field   :is_primary,    type: Boolean
end
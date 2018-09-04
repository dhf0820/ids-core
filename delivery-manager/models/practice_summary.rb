class PracticeSummary
	require 'json'
	include Mongoid::Document

	field   :id,        type: BSON::ObjectId
	field   :name,      type: String
end
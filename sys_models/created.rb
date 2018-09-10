class Created
	require 'json'
	include Mongoid::Document

	field   :user_id,   type: BSON::ObjectId
	field   :name,      type: String
	field   :on,        type: DateTime
end
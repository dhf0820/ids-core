class Address
	require 'json'
	include Mongoid::Document

	field   :line1,         type: String
	field   :line2,         type: String
	field   :city,          type: String
	field   :state,         type: String
	field   :postal_code,   type: String
	field   :country,       type: String

end
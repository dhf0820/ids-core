class DCVersion
	require 'json'
	include Mongoid::Document

	field :min,         type: String
	field :max,         type: String
end
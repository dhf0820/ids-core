class Name
	require 'json'
	include Mongoid::Document

	field   :first,         type: String
	field   :middle,        type: String
	field   :last,          type: String
	field   :full,          type: String
	field   :credentials,   type: String

	def initialize(args)
		super

	end
end
require_relative 'address'


class Contact
	require 'json'
	include Mongoid::Document

	field   :name,          type: String
	field   :email,         type: String
	field   :phone,         type: String
	field   :fax,           type: String
	field   :address,       type: Hash
	#embeds_one :address


	def initialize(args)
		super
		if args
			self.name = args[:name]
			self.email = args[:email]
			self.phone = args[:phone]
			self.fax = args[:fax]
			self.address = {}
			if args[:address]
				self.address[:line1] = args[:address][:line1]
				self.address[:line1] = args[:address][:line2]
				self.address[:city]  = args[:address][:city]
				self.address[:state] = args[:address][:state]
				self.address[:postal_code] = args[:address][:postal_code]
				self.address[:country] = args[:address][:country]
			end
		end
	end
end
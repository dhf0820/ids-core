class Status
	require 'json'
	include Mongoid::Document

	field   :state,          type: String
	field   :updated_on,     type: DateTime
	field   :user_id,        type: String
	field   :reason,         type: String

	def initialize(args)
		super
		return if args.nil?

		self.state = args[:state]
		self.updated_on = DateTime.now
		self.user_id = args[:user_id]
		self.reason = args[:reason]
	end
end
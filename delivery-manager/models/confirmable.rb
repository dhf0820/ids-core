

module Confirmable
	attr_accessor :verified_on, :verified_by_id, :verified_by_name, :code_expires_on, :confirmation_code


	def initialize (args=nil)
		return if args.nil?
		@verified_on = nil
		user = User.find(arg[:user_id])
		if user
			@verified_by_id = user.id.to_s
			@verified_by_name = user.name
		end
		@code_expires_on = args[:expires_on]
		@confirmation_code = args[:confirmation_code]
	end

	def set_confirmation()

	end

	def confirmed(user_id, code)
		if DateTime.now > @code_expires_on
			return "Confirmation code has expired"
		end
		if code != @confirmation_code
			return "Provided code is invalid"
		end
		user = User.find user_id
		return "Invalid user confirming." if user.nil?
		@verified_by_id = user.id.to_s
		@verified_by_name = user.name
		@verified_on = DateTime.now
		return "Confirmed"
	end
end
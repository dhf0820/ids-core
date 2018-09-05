

module Updateable

	def updated_by(user_id)
		return {} if user_id.blank?

		puts "changed_by: #{user_id}"
		user = User.find user_id
		if user.nil?
			return {}
		end
		self.updated = {}
		self.updated[:on] =  DateTime.now
		self.updated[:user_id] = user.id
		self.updated[:name] = user.full_name
		return self.updated
	end

	def created_by(user_id)
		puts "created_by: #{user_id}"
		return {} if user_id.blank?
		user = User.find user_id
		return {} if user.nil?
		self.created = {}
		self.created[:on] = DateTime.now
		self.created[:user_id] = user.id
		self.created[:name] = user.full_name
		return self.created
	end

	def save
		# if self.updated[:user_id].nil?
		# 	puts "Updateed_by not set!"
		# 	return false
		# end
		self.updated = {} if self.updated.nil?
		self.updated[:on] = DateTime.now
		if self.new_record
			self.created = self.updated
		end
		super
	end

end


module Updateable
  def save
    if self.new_record?
			self.created = update_info(nil)
		end
		self.updated = update_info(nil)

   super
  end
  
  private
  def update_info(user_id)
    data = {}
    data[:on] = DateTime.now
    unless user_id.nil?
      user = User.find user_id
      if user
        data[:user_id] = user.id
        data[:name] = user.full_name
      end
    end
		data
	end

end
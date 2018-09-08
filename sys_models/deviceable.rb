
module Deviceable
	def add_device(device, primary)
		puts "Add Device to #{self.full_name} - #{device}"
		remove_device(device)
		if primary
			remove_primary
			set_primary(device)
		end
		new_device = {}
		new_device[:device_id] = device.id.to_s
		new_device[:device_name] = device.name
		new_device[:class_id] = device.delivery_class_id.to_s
		new_device[:class_name] = device.delivery_class_name
		new_device[:is_primary] = primary
		self.devices << new_device
		device.owner = self
		device.save
	end

	# Remove the specified Device. If it is the current primary device, reset the primary to Mail
	def remove_device(device)
		return if self.devices.empty?
		self.devices.delete_if  {|h| h[device.id] == device.id}
		if self.primary_device[:device_id] == device.id.to_s
			set_primary(MailDeliveryClass.default_device)  # removed primary reset to MAIL
		end
	end



	def set_primary(device)
		self.primary_device = {device_id: device.id, device_name: device.name, class_id: device.delivery_class_id, class_name: device.delivery_class_name}
	end

	def get_primary_device
		prim_dev = self.devices.select {|dev| dev[:is_primary] == true}
		if prim_dev.count == 0
			return nil
		end
		prim_dev[0]
	end

	def remove_primary
		prim_dev = self.devices.select {|dev| dev[:is_primary] == true}
		if prim_dev.count > 0
			prim_dev.each do |dev|
				dev[:is_primary] = false
			end
		end
	end
end


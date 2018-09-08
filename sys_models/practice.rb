require '../sys_models/updateable'
require '../sys_models/mail_delivery_class'
require '../sys_models/deviceable'
require '../sys_models/delivery_profile'
require '../sys_models/fax_device'
require '../sys_models/fax_class'

class Practice
	require 'json'
	include Mongoid::Document
	#include Mongoid::Attributes::Dynamic
	include Updateable
	include Deviceable

	field   :id,                            type: String
	field   :name,                          type: String
	field   :owner_context,                 type: String,   default: "pra"
	field   :primary_device,                type: Hash,     default: {}
	field   :contact,                       type: Hash,     default: {}
	field   :devices,                       type: Array,    default: []
	field   :physicians,                    type: Array,    default: []
	field   :updated,                       type: Hash,     default: {}
	field   :created,                       type: Hash,     default: {}

	def initialize()
		super
		# Add default mail device/class
		self.owner_context = 'pra'
		puts "    $$$ Setting primary device mail: #{MailDeliveryClass.device.inspect}"

		self.add_device(MailDeliveryClass.device, true)

	end


	def add_physician(phy)
		phy.add_practice(self)
 # TODO Check if physician already exists in physicians list
		physicians << phy.entity
	end

	def add_device(device, primary)
		remove_device(device)
		if primary
			remove_primary
			set_primary(device)
		end
		new_device = device.summary
		new_device[:is_primary] = primary
		self.devices << new_device
	end

	# Remove the specified Device. If it is the current primary device, reset the primary to Mail
	def remove_device(device)
		return if self.devices.empty?
		puts "Before remove #{self.devices.count} devices: "
		self.devices.delete_if {|dev| dev['device_id'] == device.id}
		puts "After remove #{self.devices.count} devices: "
		if self.primary_device['device_id'] == device.id.to_s
			set_primary(MailDeliveryClass.default_device)  # removed primary reset to MAIL
		end
	end

	def set_primary(device)
		self.primary_device = {device_id: device.id.to_s, device_name: device.name, class_id: device.delivery_class_id, class_name: device.delivery_class_name}
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

	def get_primary
		puts "      ### get primary: #{self.primary_device[:device_id]}"
		DeliveryDevice.find self.primary_device[:device_id]
	end

	def add_contact(args)
		self.contact = args
	end

	# def changed_by(user_id)
	# 	user = User.find user_id
	# 	self.updated[:user_id] = user.id
	# 	self.updated[:name] = user.full_name
	# end

	def full_name
		self.name
	end

	def entity
		summary
	end

	def summary
		data = {}
		data[:ids_id] = self.id.to_s
		data[:name] = self.name
		data[:context] = self.owner_context
		data[:primary_device] = self.primary_device
		data
	end

	def save
		super
	end
end
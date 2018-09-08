# require_relative 'created'
# require_relative 'updated'
#require_relative 'contact'
#require_relative 'name'
#require_relative 'practice_summary'
#require_relative 'device_summary'
require '../sys_models/mail_class'
require '../sys_models/updateable'

require 'date'
require 'pry'

class Physician
	require 'json'
	include Mongoid::Document
	include Updateable


	#field   :_id,                   type: BSON::ObjectId
	field   :id,                    type: String
	field   :ref_physician_id,      type: String
	field   :status,                type: Hash,     default: {}
	field   :affiliated,            type: Boolean
	field   :has_privledges,        type: Boolean
	field   :hospital_id,           type: String
	field   :remote_id,             type: String
	field   :use_practice_delivery, type: Boolean,  default: false
	field   :owner_context,         type: String,   default: 'phy'
	field   :primary_practice,      type: Hash,     default: {}
	field   :primary_device,        type: Hash,     default: {}
	field   :created,               type: Hash,     default: {}
	field   :updated,               type: Hash,     default: {}
	field   :name,                  type: Hash,     default: {}
	field   :contact,               type: Hash,     default: {}
	field   :practices,             type: Array,    default: []
	field   :devices,               type: Array,    default: []

	def initialize(args = {})
		super
		self.owner_context = 'phy'
		self.contact[:address] = {}
		self.add_device(MailClass.default_device, true)
		self.status[:state] = 'new pending'
		return if args.empty?
		puts "Setting Physician #{args}"
		#self.contact = Contact.new(args[:contact])

		#binding.pry
		# puts "Initialize Args: #{args}"
		self.ref_physician_id = args[:ref_physician_id]
		name = args[:name]
		if name
			self.name[:first] = args[:first] || name[:first] || nil
			self.name[:middle] = args[:middle] || name[:middle] || nil
			self.name[:last] = args[:last] || name[:last] || nil
			self.name[:full_name] = "#{first_name} #{middle_name} #{last_name}"
		end

		# self.created[:on] = DateTime.now
		# self.created[:user_id] = args[:change_user_id] || self.created[:user_id]
		# self.created[:name] = args[:change_name][:name] || created[:name]
		#self.status = args[:status] || self.status

	end



	# def changed_by(user_id)
	# 	user = User.find user_id
	# 	self.updated[:user_id] = user.id
	# 	self.updated[:name] = user.full_name
	# end

	def phy_name=(args)
		self.name = {} if self.name.nil?
		self.name[:first] =  args[:first] || self.name[:first]|| nil
		self.name[:middle] = self.name[:middle] || args[:middle] || nil
		self.name[:last] = args[:last] || self.name[:last] || nil
		self.name[:credentials] = self.name[:credentials] || args[:credentials] || nil
		self.name[:full_name] = "#{first_name} #{middle_name} #{last_name}"
		#args[:full_name] || self.name[:full_name] || "#{self.name[:first]} #{self.name[:middle]} #{self.name[:last]}"
	end


	def add_device(device, primary)
		remove_device(device)
		if primary
			remove_primary
			set_primary(device)
		end
		new_device = {}
		new_device[:device_id] = device.id
		new_device[:device_name] = device.name
		new_device[:class_id] = device.delivery_class_id
		new_device[:class_name] = device.delivery_class_name
		new_device[:is_primary] = primary
		self.devices << new_device
	end

	# Remove the specified Device. If it is the current primary device, reset the primary to Mail
	def remove_device(device)
		return if self.devices.empty?
		self.devices.delete_if  {|h| h[device.id] == device.id}
		if self.primary_device[:id] == device.id
			set_primary(MailClass.default_device)  # removed primary reset to MAIL
		end
	end

	def set_primary(device)
		self.primary_device = {id: device.id, name: device.name, class_id: device.delivery_class_id, class_name: device.delivery_class_name}
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

	def add_practice(practice)
		self.practices << practice.summary
		if self.practices.count = 0
			self.primary_practice = practice.summary
		else
			self.primary_practie = nil
		end
	end

	def remove_practice(id)
		self.practices.delete_if  {|h| h[:prac_id] == prac_id}
	end


	def add_contact(args)
		self.contact = args
		# self.contact[:name] = args[:name] || self.contact[:name]
		# self.contact[:email] = args[:email] || self.contact[:email]
		# self.contact[:phone] = args[:phone] || self.contact[:phone]
		# self.contact[:fax] = args[:fax] || self.contact[:fax]
		# self.contact[:address][:line1] = args[:address] || self.contact[:address]
	end


	def first_name
		self.name[:first]
	end

	def first_name=(fname)
		self.name[:first] = fname
	end

	def middle_name
		self.name[:middle]
	end

	def middle_name=(mname)
		self.name[:middle] = mname
	end

	def last_name
		self.name[:last]
	end

	def last_name=(lname)
		self.name[:last] = lname
	end

	def full_name=(full_name)
		self.name[:full_name] = full_name
	end

	def full_name
		self.name[:full_name]
	end

	def summary
		data = {}
		data[:ids_id] = self.id.to_str
		data[:name] = self.full_name
		data[:context] = self.owner_context
		data[:remote_id] = self.remote_id
		data[:primary_device] = self.primary_device
		data[:practice] = self.primary_practice
		data[:num_practices] = self.practices.count
		data
	end

	def save
		super
	end
end
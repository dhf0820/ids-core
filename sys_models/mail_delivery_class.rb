
require '../sys_models/delivery_class'
require '../sys_models/mail_delivery'

class MailDeliveryClass < DeliveryClass
	@@mail = nil
	@@mail_device = nil

	def initialize()
		@@mail = MailDeliveryClass.first  #.where(name: 'Mail').first
		if @@mail
			raise IdsError.new('Mail Delivery class is already set up. Use it.')
		end
		super
		self.name = 'Mail'
		self.description = 'Daily Mail Batch'

		self[:validation_required] = false
		self.save
		@@mail = self

	end
	def self.default
		@@mail = MailDeliveryClass.first
		if @@mail.nil?
			puts "   @@@  Create Default Mail"
			@@mail = MailDeliveryClass.new()
			@@mail.save
		end
		@@mail
	end

	def self.default_device
		return self.device
		self.default
		if @@mail_device.nil?
			@@mail_device = MailDelivery.first #find(@@mail.devices[0][:id])
		end

		@@mail_device
	end


	def self.device
		self.default
		MailDelivery.default
	end

	def extend()
		#puts "Extend MailDeliveryClass:"
		self.name = 'Mail'
		self.description = 'Daily mail batch'
		self.status = {}
		self.status[:state] = "Active"
		self.status[:reason] = "Initial System"
		self.write_attribute(:mail,  {} )   #what delivery for Mail require.

#TODO Set printer information
		self.delivery_details[:printer_name] = ""
		self.delivery_details[:printer_uri] = ''
		self.save
		md = MailDelivery.first
		if md.nil?
			md = MailDelivery.new
		else
			puts "   ###$$$ MailDelivery already exists: #{md.inspect}"
		end

		md.name = "Mail"
		md.delivery_class_id = self.id
		md.delivery_class_name = self.name
		md.save
		self.add_device(md)
	end

	# def create_device(owner)
	# 	device = MailDelivery.new
	# end


end

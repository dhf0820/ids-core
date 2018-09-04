require './models/updateable'
require './models/ids_error'


class DeliveryClass
	require 'json'
	include Mongoid::Document
	include Updateable
	include Mongoid::Attributes::Dynamic

	field :id,                  type: String
	field :name,                type: String
	field :description,         type: String
	field :device_type,         type: String
	field :status,              type: Hash,     default: {state: 'testing', reason: 'created', on: DateTime.now}
	field :devices,             type: Array,    default: []
	field :updated,             type: Hash,     default: {}
	field :created,             type: Hash,     default: {}
    field :delivery_details,    type: Hash,     default: {}
    field :queue_name,          type: String

	def initialize()
		super
		self.extend()
	end

	def extend()
		#return if args.nil?
		raise IdsError.new("Extend method is required")
	end

	def add_device(device)
		remove_device(device.id)
		device.delivery_class_id = self.id.to_s
		device.delivery_class_name = self.name
		device.save
		new_device = {}
		new_device[:id] = device.id.to_s
		new_device[:name] = device.name
		self.devices << new_device
	end

	def remove_device(device_id)
		return if self.devices.empty?
		self.devices.delete_if  {|h| h[device_id] == device_id}
	end
end
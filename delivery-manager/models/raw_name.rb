class RawName
	require 'json'
	include Mongoid::Document
	include Updateable
	include Mongoid::Attributes::Dynamic

	@@inactive_status_types = %w(new, unknown, unlinkable)

	field   :raw_name,          type: String
	field   :actual_name,       type: String
	field   :name_key,          type: String
	field   :status,            type: String
	field   :entity,            type: Hash
	field   :updated,           type: Hash, default: {}
	field   :created,           type: Hash, default: {}


	def self.create_raw_name(entity)
		rn = RawName.new
		rn.raw_name = entity[:name].downcase
		rn.actual_name = entity[:name]
		rn.name_key = RawName.make_keyname(entity[:name])
		rn.entity = entity
		rn.status = 'active'
		rn.save
		rn
	end

	def self.lookup(name)
		rn = RawName.where(name_key: RawName.make_keyname(name)).first
		if rn.nil?
			puts "Creating a new RawName for #{name}"
			rn = RawName.new_raw_name(name)
			rn.save
		end
		rn
	end


	def link(entity, status = 'active')
		#self.actual_name = name
		self.status = status
		self.entity = entity.entity  #{id: id, context: context, name: self.actual_name}
		self.entity.delete('primary_device')
		self.actual_name = self.entity[:name]
		self.save
		delivered = 0
		#TODO Delivery all pending for this provider per profile
		delivered    # number of reports pending that where delivered
	end

	def unlink(status)
		if @@inactive_status_types.include?(status)
			self.actual_name = nil
			self.entity = nil
			self.status = status
			self.save
			return true
		else
			return false
		end
	end

	#protected


	def self.new_raw_name(name)
		rn = RawName.new()
		rn.raw_name = name.downcase
		rn.name_key = rn.make_keyname()
		rn.status = 'new'
		rn.save
		rn
	end

	#private




	def self.make_keyname(name)
		comp_name = name.gsub(' ', '')
		comp_name.gsub!(".", '')
		comp_name.gsub!(",",'')
		comp_name.downcase
	end

	def make_keyname
		RawName.make_keyname(self.raw_name)
	end
end
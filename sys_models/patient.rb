
require 'date'
require 'pry'
require '../sys_models/updateable.rb'
require 'rest-client'



class Patient
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic

	field   :id,        type: String
	field   :name,      type: String
	field   :first_name, type: String
	field   :middle_name, type: String,     default: ''
	field   :last_name,  type: String
	field   :mrn,       type: String
	field   :birth_date,       type: Date
	field   :marital_status,  type: String, default: ''
	field   :sex,       type: String,   default: ''
	field   :ssn,       type: String,   default: ''
	field   :remote_id, type: String
	field   :visits,    type: Array,    default: []
	field   :updated,   type: Hash,     default: {}
	field   :created,   type: Hash,     default: {}

	# def initialize()
	# 	super
	#
	# 	#return if args.nil?
	# 	# self.name = args[:name]
	# 	# self.mrn = args[:mrn]
	# 	# self.ssn = args[:ssn]
	# 	# if args[:dob]
	# 	# 	begin
	# 	# 		self.dob =  Date.strptime(args[:dob], "%m/%d/%Y")   #Note format required
	# 	# 	rescue => er
	# 	# 		raise IdsErr.new("DOB error: #{er.message}")
	# 	# 	end
	# 	# end
	# 	# if args[:visit]
	# 	# 	# visit = {}
	# 	# 	# visit[:number] = args[:visit][:number]
	# 	# 	# visit[:account_id] = args[:visit][:account_id]
	# 	# 	self.visits << {number: args[:visit][:number], account_id: args[:visit][:account_id]}
	# 	# end
	# end


	def Patient.by_mrn(value)
		#puts "Looking for MRN: #{value}"
		pat = Patient.where(mrn: value).first
		# if pat.nil?  # need to get from remote
		# 	puts "Patient #{value} not found locally retrieve from remote"
		# 	pat = Config.active.remote.patient_by_mrn(value)
		# end
		# if pat.nil?   # not found locally or on remote
		# 	p = $remote.create_patient(self)
		# 	pat.remote_id = p.remote_id
		# 	pat.save
		# end
		pat
	end

  def Patient.remote_by_mrn(value)
    Config.active.remote.patient_by_mrn(value)
  end
  
	def Patient.by_remote_id(rem_id)
		pat = self.where(remote_id: rem_id).first
		if pat.nil?
			pat = $remote.patient_by_remote_id(rem_id)
		end
	end

	def update_remote()
		pat = $remote.patient_update(self)
		self.remote_id = pat.remote_id
	end


	def add_remote
		pat = $remote.patient_create(self)
		self.remote_id = pat.remote_id
  end
  
	def summary
		data = {}
		#data[:id] = self.id.to_s
		data['ids_id'] = self.id.to_s
		data['remote_id'] = self.remote_id
		data['mrn'] = self.mrn
		data['name'] = self.name
		data
	end

	def add_visit(visit)
		visit.patient_id = self.id
		visit.patient = self.summary
		visit.save
		self.visits << visit.summary
	end

	def save
		make_name
		# new_rec = self.new_record
		# if new_rec== true
		# 	# check if on remote already
		# 	pat = $remote.patient_by_mrn(self.mrn)
		# 	puts "Patient by mrn: #{pat.inspect}"
		# 	if pat.nil?
		# 		#binding.pry
		# 		pat = $remote.create_patient(self)
		# 		puts "REmote patient created: #{pat.inspect}"
		# 	end
		# 	self.remote_id = pat.remote_id
		# end
		super
		# if new_rec == true
		# 	p = update_remote
		# 	binding.pry
		# end
	end



	def split_name()
		if self.name.blank?
			$log.warn "Patient name is blank"
			raise SaveFailure "Patient name is blank"
		end
#TODO Check if name contains a comma if does not it is first last
		names = self.name.split(',')
		if names.count > 1      # comma lastname first
			self.last_name = names[0].strip
			self.first_name = names[1].strip
			if names.count > 2
				self.middle_name = names[2].strip
			end
		else
			names = self.name.split(' ')

			if names.count < 3
				self.first_name = names[0]
				self.last_name = names[1]
			else
				self.first_name = names[0]
				self.middle_name = names[1]
				self.last_name = names[2]
			end
		end
	end




	def default_account
		"default-#{remote_id}"
	end

	def make_name
		self.name = "#{self.first_name} #{self.middle_name} #{last_name}"
	end


	def default_visit
		v = Visit.where(visit_num: "default-#{remote_id}").first
		if v.blank?
			v = create_default_visit("default-#{remote_id}")
		end
		v
	end

	private

	def create_default_visit(visit_num)
		v = Visit.new
		v.number =  visit_num
		v.patient_id = id
		#v.account_id = account_id
		v.comment = "Catchall visit"
		v.status = "Catchall Visit"
		#v.facility = facility
		begin
			v.save
		rescue Exception => e
			puts "Catchall visit for #{id} failed: #{e}"
			return nil
		end
		v
	end

	def visit(visit_num)
		Visit.where(:patient_id=> id, :number => visit_num)
	end

end

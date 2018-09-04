
require 'date'
require 'pry'
require './models/updateable.rb'
require 'rest-client'



class Patient
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic

	field   :id,        type: String
	field   :name,      type: String
	field   :first_name, type: String
	field   :middle_name, type: String
	field   :last_name,  type: String
	field   :mrn,       type: String
	field   :birth_date,       type: Date
	field :marital_status,  type: String
	field   :sex,       type: String
	field   :ssn,       type: String
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


	def self.by_mrn(value)
		pat = self.where(mrn: value).first
		if pat.nil?  # need to get from remote
			pat = $remote.patient_by_mrn(value)
		end
	end

	def self.by_remote_id(rem_id)
		pat = self.where(remote_id: rem_id).first
		if pat.nil?
			pat = $remote.patient_by_remote_id(id)
		end
	end

	def update_remote()
		pat = $remote.patient_update(self)
		pat
	end

	def summary
		data = {}
		data[:id] = self.id
		data[:remote_id] = self.remote_id
		data[:mrn] = self.mrn
		data[:name] = self.name
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
		if new_record
			add_remote
		end
		super


	end

	def add_remote

	end
	private

	def make_name
		self.name = "#{self.first_name} #{self.middle_name} #{last_name}"
	end
end

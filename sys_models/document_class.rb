require '../sys_models/updateable'
require '../sys_models/ids_error'
require 'mongoid'

class DocumentClass
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic

	field :id,                  type: String
	field :code,                type: String
	field :description,         type: String
	field :remote_id,           type: String
	field :repository,          type: String
	field :internal,            type: Boolean
	field :document_types,      type: Array, default: []
	field :priority,            type: Hash, default: {}
	field :updated,             type: Hash, default: {}
	field :created,             type: Hash, default: {}

	# def initialize(args = nil)
	# 	super
	# 	return if args.nil?
	# 	self.code = args[:code]
	# 	self.description = args[:description]
	# 	self.chart_archive_id = args[:chart_archive_id]
	# 	#self.status = args[:status] || {}
	# end

	def add_type(dt)
		dt.document_class = self.summary
		dt.save
    self.document_types << dt.summary
    save
		dt.summary
	end

	def remove_type()

	end

	def summary
		data = {}
		data['ids_id'] = self.id.to_s
		data['code'] = self.code
		data['description'] = self.description
		data['remote_id'] = self.remote_id
		data
	end

	def self.create_class(code, description, rem_id)
		dc = DocumentClass.new
		dc.code = code
		dc.description = description
		dc.remote_id = rem_id
		dc.save
		dc
	end

	def self.load_class(rem_id)
		rdc = $remote.load_document_class(rem_id)
		dc = DocumentClass.new


	end

	def self.by_code(value)
		DocumentClass.where(code: value).first
	end

	def self.for_remote_id(value)
		DocumentClass.where(remote_id: value).first
	end
end
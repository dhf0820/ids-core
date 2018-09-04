require './models/updateable'
require './models/ids_error'


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
		dt.summary
	end

	def remove_type()

	end

	def summary
		data = {}
		data[:ids_id] = self.id.to_s
		data[:code] = self.code
		data[:remote_id] = self.remote_id.to_s
		data
	end

	def self.by_code(value)
		DocumentClass.where(code: value).first
	end
end
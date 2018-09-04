require './models/updateable'
require './models/ids_error'
require './models/document_class'


class DocumentType
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic


	field :id,                  type: String
	field :code,                type: String
	field :description,         type: String
	field :remote_id,           type: String
	field :document_class,      type: Hash, default: {}
	field :updated,             type: Hash, default: {}
	field :created,             type: Hash, default: {}


	# def initialize(args = nil)
	# 	super
	#
	# 	return if args.nil?
	# 	self.code = args[:code]
	# 	self.description = args[:description]
	# 	self.chart_archive_id = args[:chart_archive_id]
	# 	if args[:doc_class].class == DocumentClass
	# 		self.document_class[:id] = args[:doc_class].id
	# 		self.document_class[:code] = args[:doc_class].code
	# 	end
	# 	#self.status = args[:status] || {}
	# end

	def info
		data =  {}
		data[:ids_id] = self.id.to_s
		data[:code] = self.code
		data[:class_id]  = self.document_class[:ids_id].to_s
		data[:class_code] = self.document_class[:code]
		data
	end

	def summary
		data = info
		data[:remote_id] = self.remote_id.to_s
		data[:class_remote_id] = self.document_class[:remote_id].to_s
		data[:description] = self.description
		data
	end



	def self.by_code(code)
		self.where(code: code).first
	end

	def self.by_class_id(class_id)
		self.where("document_class.id" => class_id )
	end
end
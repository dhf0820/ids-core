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


	def DocumentType.for_remote_id(remote_id)
		DocumentType.where(remote_id: remote_id).first
	end

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

	def summary
		data =  {}
		data[:ids_id] = self.id.to_s
		data[:code] = self.code
		data[:description] = self.description
		data[:remote_id] = self.remote_id
		data
	end

	def load(dt)
		#puts "Load: #{dt}"
		self.remote_id = dt['remote_id']
		self.code = dt['code']
		self.description = dt['description']
		return nil if(dt['document_class'].nil?)
		self.save

		dc_remote_id = dt['document_class']['remote_id']
		dc = DocumentClass.for_remote_id(dc_remote_id)
		if dc.nil?
			dc_code = dt['document_class']['code']
			dc_description = dt['document_class']['description']
			dc = DocumentClass.create_class(dc_code, dc_description, dc_remote_id)
			dc.save
		end
		dc.add_type(self)
		dc.save
		self
		#dt is updated and saved
	end


	def self.by_code(code)
		self.where(code: code).first
	end

	def self.by_remote_id(rem_id)
		self.where(remote_id: rem_id).first
	end

	def self.by_class_id(class_id)
		self.where("document_class.id" => class_id )
	end

	def self.load_types
		types = $remote.document_types
		types.each do |t|
			if(t['document_class'].nil?)  # DocumentTYpe must belong to a document Class
				puts "Invalid Document Type no Document Class: #{t}"
				next
			end
			dt = DocumentType.for_remote_id(t['remote_id'])
			if dt.nil?
				dt = DocumentType.new
			end
			# either update or create the document_type anbd class
			dt.load(t)
		end
	end

	def self.load_type(rem_id)
		dt = self.by_remote_id(rem_id)
		if dt.nil?
			rtype = $remote.document_type(rem_id)
			return nil if rtype.nil?
			dt = DocumentType.new
			dt.load(rtype)
		end
	end
end
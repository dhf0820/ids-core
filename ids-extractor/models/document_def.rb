require '../sys_models/updateable'
require '../sys_models/ids_error'

#module IDSReader
	class DocumentDef
		require 'json'
		include Mongoid::Document
		include Updateable

		field   :name,              type: String
		field   :document_type,     type: String
		field   :definition,        type: String
		field   :updated,           type: Hash,     default: {}
		field   :created,           type: Hash,     default: {}

	end

	def DocumentDef.by_name(name)
		DocumentDef.where(name: name).first
	end

#end
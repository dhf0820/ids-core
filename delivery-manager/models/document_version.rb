require './models/updateable'
require './models/ids_error'


class DocumentVersion
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic

	field :id,                  type: String
	field :doc_ref,             type: String
	field :remote_id,           type: String
	field :version_number,      type: Integer
	field :rept_datetime,       type: DateTime
	field :recv_datetime,       type: DateTime
	field :image_id,            type: String
	field :clinical_summary,    type: Hash, default: {}
	field :updated,             type: Hash, default: {}
	field :created,             type: Hash, default: {}


	def summary
		data = {}
		data[:id] = self.id
		data[:remote_id] = self.remote_id
		data[:version] = self.version_number
		data[:image_id] = self.image_id
		data[:doc_ref] = self.doc_ref
		data[:rept_date] = self.rept_datetime
		data
	end

	def save
		super
	end
end
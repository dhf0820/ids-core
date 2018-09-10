require './models/updateable'
require './models/ids_error'

class SampleDocument
	require 'json'
	include Mongoid::Document
	include Updateable


	field   :facility,      type:   String
	field   :source,        type:   String
	field   :document_type, type:   String
	field   :live_data,     type:   DateTime
	field   :status,        type:   String
	field   :comment,       type:   String
	field   :created,       type:   Hash
	field   :updated,       type:   Hash
	field   :image,         type:   Binary

end





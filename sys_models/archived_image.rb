require '../sys_models/updateable'
require '../sys_models/ids_error'

class ArchivedImage
	require 'json'
	include Mongoid::Document
    include Updateable
    
	field :id,                  type: String
	field :remote_id,           type: String
	field :pages,               type: Integer
	field :facility,            type: String
	field :doc_info,            type: Hash,     default: {}
	field :patient,             type: Hash,     default: {}
	field :updated,             type: Hash,     default: {}
	field :created,             type: Hash,     default: {}
	field :internal_image,      type: BSON::Binary     

	def ArchivedImage.by_remote_id(rem_id)
		begin
			ai = $remote.image_by_remote_id(rem_id)
		rescue IdsError => ex
			case ex.code
			when 401
				$remote.login('dhfrench@gmail.com')
				ai = $remote.image_by_remote_id(rem_id)
			when 404
				#binding.pry
				return nil
			end
		end
		return ai
	end
end
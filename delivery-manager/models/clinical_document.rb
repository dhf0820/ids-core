require './models/updateable'
require './models/ids_error'

class ClinicalDocument

	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic

	field :id,                  type: String
	field :remote_id,           type: String
	field :doc_ref,             type: String
	field :rept_date,           type: DateTime
	field :recv_date,           type: DateTime
	field :version_num,         type: Integer,  default: 0
	field :pages,               type: Integer
	field :facility,            type: String
	field :description,         type: String
	field :type_info,           type: Hash,     default: {}
	field :patient,             type: Hash,     default: {}
	field :visit,               type: Hash,     default: {}
	field :updated,             type: Hash,     default: {}
	field :created,             type: Hash,     default: {}
	field :internal_image,      type: String             # Base64 encoded Encrypted Image



	def self.by_remote_id(rem_id)
		cdoc = self.where(remote_id: rem_id).first

		if cdoc.nil?
			begin
				cdoc = $remote.document_by_remote_id(rem_id)
			rescue IdsError => ex
				#binding.pry
				case ex.code
				when 401
					$remote.login('dhfrench@gmail.com')
					cdoc = $remote.document_by_remote_id(rem_id)
				when 404
					return nil
				end
			end
		end
		cdoc
	end

	# decode then decrypt the internal image
	def image
		decrypt( decode_image(self.internal_image))
	end

	def image=(raw_image)
		self.internal_image = encode_image(encrypt(raw_image))
	end

	def decode_image(encoded_image)
		Base64.decode64(encoded_image)
	end

	def encode_image(unencoded_image)
		Base64.encode64(unencoded_image)
	end

	def encrypt(unencrypted_image)
		 unencrypted_image   # for now testing
	end

	def decrypt(encrypted_image)
		encrypted_image     # for now testing
	end

	#TODO add_version is not valid need reral
	#
	# def add_version(ver, image)
	# 	self.inc(current: 1)
	# 	ver.version_number = self.current
	# 	ver.clinical_summary = self.summary
	# 	ver.image_id = '12351'
	# 	ver.save
	# 	versions << ver.summary
	# 	self.current_version = ver.summary
	# 	ver
	# end


	def summary()
		data = {}
		data['ids_id'] = self.id
		data['remote_id'] = self.remote_id
		data['patient_id'] = self.patient_id
		data['visit_id'] = self.visit_id
		data['type_id'] = self.type_id
		data['version'] = self.version_number  #current_version
		data
	end

	def save
		newrec = self.new_record
		super
		puts "Saving remote document"
		if newrec
			doc = $remote.document_save(self)
			doc.save
		end
	end

end

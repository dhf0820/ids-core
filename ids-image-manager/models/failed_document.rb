require 'base64'
require 'date'

class FailedDocument
	require 'json'
	include Mongoid::Document

	field   :facility,      type: String
	field   :data,          type: Hash,     default: {}
	field   :source,        type: String
	field   :job_id,        type: String
	field   :received_date, type: DateTime
	field   :document_type, type: String
	field   :live_date,     type: DateTime
	field   :status,        type: String
	field   :failed_reason, type: String
	field   :enc_image,     type: BSON::Binary


	# base64 encode then encrypt image
	def image=(raw_image)
		self.enc_image = Base64.encode64(raw_image)
	end

	# todo decrypt thenbase64 decode image
	def image
		Base64.decode64(enc_image)
	end

	def date_received=(rec_date)
		begin
			reeceived_date = Date.strptime(rec_date, "%mm/%dd/%YYYY %H%M")
		rescue =>ex
			return nil
		end
		return received_date
	end

	def date_received
		return nil if received_date.nil?
		received_date.strftime("%mm/%dd/%YYYY %H%M")
	end
end
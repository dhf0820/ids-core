require './models/delivery_device'

class FaxDevice < DeliveryDevice
	def extend(args = nil)
		fc = FaxClass.default
		self.device_class = fc
		self.queue_details[:fax_number] = ""
		true
	end


	def fax_number=(fnumber)
		self.queue_details[:fax_number] = fnumber
	end

	def fax_number
		self.queue_details[:fax_number]
	end


	#FaxNumber wil be added the first time the faxclass attempts to send a document
	def summary
		s = super
		s[:fax_number] = self.fax_number
		s
	end

	def queue(clin_doc, recipient)

		delv_req = DeliveryRequest.new
		delv_req.device = self.summary
		delv_req.device_id = self.id.to_s
		delv_req.device_class_id = self.delivery_class_id
		delv_req.recipient = self.owner
		delv_req.patient = clin_doc.patient
		delv_req.document = clin_doc.summary
		delv_req.queued_time = DateTime.now
		delv_req.command = self.fax_number
		delv_req.save
		delv_req
	end

	def request_validation
		validation[:submit_date] = DateTime.now
		unless validation[:verified_date]              # number has not been validated
			validation[:verified_date] =  nil
			validation[:status] = :initial
			# else                                    # number is being revalidated
			# 	validation[:status] = :revalidate
		end
		validation[:confirmation_code] = rand(36**code_length).to_s(36)
		self.save
	end

	def validate(code)
		if code == validation[:confirmation_code]
			validation[:verified_date] = DateTime.now
			validation[:status] =  :active
			validation[:confirmation_code] = ''
			self.save
			true
		else
			false
		end
	end

	private

	def code_length
		Config.code_length
	end
end
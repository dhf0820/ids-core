require 'spec_helper'
require './models/mail_delivery_class'
require "./models/mail_delivery"
require './models/patient'
require './models/clinical_document'
require './models/raw_name'
require './models/ids_error'
require './spec/factories/mail_class'
require './spec/factories/mail_delivery'
require './spec/utilities/delivery_setup'


RSpec.describe MailDelivery, type: :model do

	describe 'creating MailDelivery device' do
		before :each do
			@mdc = MailDeliveryClass.default

		end
		it 'should not allow more than one MailDelivery device' do
			expect(MailDelivery.all.count).to eql 1
			expect{MailDelivery.new}.to raise_error(IdsError) #'Default Mail Delivery Device already exists, use it')
		end
	end

	# describe 'delivery queueing' do
	# 	before :context do
	# 		@ds = DeliverySetup.new
	# 		@doc_class = @ds.document_class_type('consult')
	# 		@tefrench = Patient.new(name: 'Theresa French', mrn: 'te1015')
	# 		@tefrench.save
	# 		@clin_doc = ClinicalDocument.new(patient_id: @tefrench, type_id: @doc_class.document_types[0][:id])
	# 		@clin_doc.save
	# 		@prac = @ds.create_none_practice
	# 		@raw = RawName.lookup(@prac.full_name)
	# 	end
	#
	# 	it 'should not queue a document for delivery anywhere' do
	# 		dev = MailDeliveryClass.default_device
	# 		doc_summary = {}
	# 		doc_summary[:id] = @clin_doc.id
	# 		doc_summary[:version_id] = 1234
	# 		doc_summary[:image_id] = 9876
	# 		doc_summary[:image] = nil
	# 		qr = dev.queue(doc_summary, @prac.summary, @tefrench.summary)
	# 		qr = DeliveryRequest.first
	# 		expect(qr).to_not be_nil
	# 	end
	# end

	describe 'delivery queueing' do
		before :each do
			puts "\n\n     $$$ Number of Mail devices: #{MailDelivery.count}\n\n\n"
			@ds = DeliverySetup.new
			@doc_class = @ds.document_class_type('consult')
			@doc_type = DocumentType.find @doc_class.document_types[0][:ids_id]
			@type_info = @doc_type.info #{id: @doc_type.id, code: @doc_type.code, class_id: @doc_type.document_class[:class_id],
			              #class_code: @doc_type.document_class[:code]}
			@tefrench = @ds.create_patient()
			@visit = @ds.create_visit('tfv1234', @tefrench)

			@clin_doc = @ds.clinical_document(@tefrench, @visit, @type_info)
			@image = nil
			@prac = @ds.create_mail_practice
puts "\n\n   @@@  default Mail Device: #{MailDelivery.default.inspect}\n\n"
puts "\n\n   @@@  default Mail Class Device: #{MailDeliveryClass.device.inspect}\n\n"
puts "\n\n   @@@ practice #{@prac.inspect}\n\n"
puts "\n\n   @@@ practice default Device #{@prac.primary_device}\n\n"
			@raw = RawName.lookup(@prac.full_name)
		end

		it 'should queue a document for delivery to nightly print' do
puts "\n\n   @@@ practice #{@prac.inspect}\n\n"
			md = @prac.get_primary #DeliveryDevice.find @prac.primary_device[:id]
			qr = md.queue(@clin_doc, @prac.summary)
			qr = DeliveryRequest.first
			expect(qr.device[:device_id]).to eql md.id.to_s
			expect(qr.device[:class_id]).to eql md.delivery_class_id.to_s

		end
	end


end
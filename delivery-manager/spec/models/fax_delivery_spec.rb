require 'spec_helper'
require './models/fax_class'
require './models/fax_device'
require './models/patient'
require './models/clinical_document'
require './models/raw_name'
#require './spec/factories/fax_class'
require './spec/utilities/delivery_setup'



RSpec.describe FaxDevice, type: :model do
	before :all do
		@ds = DeliverySetup.new
	end

	it 'should create a valid fax device for 855-998-7638', focus: true do
		fc = FaxClass.new
		fc.save
		prac = @ds.create_fax_practice

		fd = FaxDevice.new()
		fd.fax_number = '855-996-7638'
		fd.name = "Fax VSOFT"
		fd.description = 'Office Fax VSOFT'
		fd.owner = prac.entity
		fd.save
		fd = FaxDevice.find fd.id
		expect(fd.fax_number).to eql '855-996-7638'
	end



	describe 'delivery queueing' do
		before :context do
			@ds = DeliverySetup.new
			@doc_class = @ds.document_class_type('consult')
			@doc_class.save
			@tefrench = @ds.create_patient
			@visit = @ds.create_visit('tfv1234', @tefrench)
			@doc_type = DocumentType.find @doc_class.document_types[0][:ids_id]
			@type_info = {id: @doc_type.id, code: @doc_type.code, class_id: @doc_type.document_class[:ids_id],
			              class_code: @doc_type.document_class[:code]}

			@clin_doc = @ds.clinical_document(@tefrench, @visit, @type_info)

			@prac = @ds.create_fax_practice
			@raw = RawName.lookup(@prac.full_name)
		end

		it 'should queue a document for delivery to nightly print' do
			dev = @prac.get_primary
			qr = dev.queue(@clin_doc, @prac)
			qr = DeliveryRequest.first
			expect(qr.device_id).to eql dev.id.to_s
			expect(qr.device_class_id).to eql dev.delivery_class_id.to_s
		end
	end

end
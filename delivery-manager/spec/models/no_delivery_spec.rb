require 'spec_helper'
require './models/no_delivery_class'
require "./models/no_delivery"
require './models/patient'
require './models/clinical_document'
require './models/raw_name'

require './spec/utilities/delivery_setup'


RSpec.describe NoDelivery, type: :model do
	before :each do
		if( NoDeliveryClass.all.count) == 0
			@ndc = NoDeliveryClass.new
		end

	end


	describe 'creating NoDelivery device', focus: true do
		it 'should not allow more than one NoDelivery device', focus: true do
			expect{NoDelivery.new}.to raise_error('NoDelivery device already exists')
		end
	end

	describe 'delivery queueing', focus: true do
		before :context do
			@ds = DeliverySetup.new
			@doc_class = @ds.document_class_type('consult')
			@tefrench = Patient.new(name: 'Theresa French', mrn: 'te1015')
			@tefrench.save
			@clin_doc = ClinicalDocument.new(patient_id: @tefrench, type_id: @doc_class.document_types[0][:id])
			@clin_doc.save
			@prac = @ds.create_none_practice
			@raw = RawName.lookup(@prac.full_name)
		end

		it 'should not queue a document for delivery anywhere' do
			dev = NoDeliveryClass.default_device
			doc_summary = {}
			doc_summary[:id] = @clin_doc.id
			doc_summary[:version_id] = 1234
			doc_summary[:image_id] = 9876
			doc_summary[:image] = nil
			qr = dev.queue(doc_summary, @prac.summary, @tefrench.summary)
			qr = DeliveryRequest.first
			expect(qr).to be_nil
		end
	end


end
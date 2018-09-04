require 'rspec'
#require './spec_helper'
require './spec/utilities/delivery_setup'
require './models/mail_delivery_class'
require './models/mail_delivery'
require './models/no_delivery_class'
require './models/delivery_manager'
require './models/patient'
require './models/clinical_document'
require './models/environment'
require './lib/work_queue'



RSpec.describe DeliveryManager, type: :model, focus: true do
	before :suite do
		puts "Initializing RabbitMQ"
	end

	before :each do
		puts "Before each"

		@ds = DeliverySetup.new
		@ds.create_environment
		@ds.create_rabbit

		@doc_class = @ds.document_class_type('consult')
		@doc_class.save
		@tefrench = @ds.create_patient
		@visit = @ds.create_visit('tfv1234', @tefrench)
		@doc_type = DocumentType.find @doc_class.document_types[0][:ids_id]
		# @type_info = {id: @doc_type.id, code: @doc_type.code, class_id: @doc_type.document_class[:ids_id],
		#              class_code: @doc_type.document_class[:code]}

		@doc_info = @doc_type.summary
		@clin_doc = @ds.clinical_document(@tefrench, @visit, @doc_info)
			#ClinicalDocument.new(patient: @tefrench, type_id: @doc_class.document_types[0][:id])


		@dm = DeliveryManager.new
		@prac = @ds.create_practice
		@raw = RawName.lookup(@prac.full_name)
		@data = {}
		@data['doc_id'] = @clin_doc.id.to_s
		# @dp = DeliveryProfile.add_profile(@type_info, @prac.primary_device, @prac.summary, [:cc, :generating])
		# @dp.save
		#, type_id: @doc_class.document_types[0][:id])
	end

	after :each do
	puts "After each"


	end


	it 'should create a mail delivery request with no profile' do
		# @dp = DeliveryProfile.create_type_profile(@type_info, @prac.primary_device, @prac.summary, [:cc, :generating])
		# @dp.save
		@data['cc1'] = @prac.full_name
		@dm.process_job(@data)
		drs = DeliveryRequest.all
		expect(drs.count).to eql 1

	end

	it 'should create delivery for cc2 in data hash' do
		doc = ClinicalDocument.by_remote_id(114)
		md = MailDelivery.default
		md.entity = @prac
		md.save
		@dp = DeliveryProfile.create_type_profile(@doc_type, MailDeliveryClass.device, @prac, [:cc, :generating])
		@dp.save
		@data['cc1'] = @prac.full_name
		@data['phy-1'] = @prac.full_name
		@dm.process_job(@data)
		drs = DeliveryRequest.all
		expect(drs.count).to eql 1
	end

	it 'should not create a new delivery request when not wanted' do

		@dp = DeliveryProfile.create_type_profile(@doc_type, NoDeliveryClass.default_device, @prac, [:cc, :generating])
		@dp.save
		@data['cc1'] = @prac.full_name
		@dm.process_job(@data)
		drs = DeliveryRequest.all
		expect(drs.count).to eql 0
	end


	it 'should queue to Pending Delivery for new physician' do
		# phy = Physician.new(name: {first: 'Theresa', last: 'French'})
		# @dp = DeliveryProfile.add_profile(@type_info, phy.primary_device, phy.summary, [:cc])
		# @dp.save
		# rn = RawName.create_raw_name(phy.summary)
		# expect(rn.entity).to eql phy.summary

		@data['cc1'] = 'theresa french'
		@data['cc2'] = 'theresa french'
		@dm.process_job(@data)
		expect(PendingDelivery.all.count).to eql 1
	end
end
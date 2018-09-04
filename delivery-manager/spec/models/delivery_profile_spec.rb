require './spec/utilities/delivery_setup'
require 'rspec'
require 'spec_helper'
 require './models/delivery_profile'
#require './models/delivery_manager'
require './models/delivery_request'
# require './models/document_class'
require './models/document_type'
require './models/patient'
require './spec/factories/patient'
require './spec/factories/visit'
# require './models/delivery_class'
# require './models/delivery_device'
# require './models/practice'
# require './models/physician'
# require './models/guid'
require './spec/utilities/delivery_setup'

RSpec.describe DeliveryProfile, type: :model do


	describe 'Practices default to practice primary delivery ' do
		before :all do
			@ds = DeliverySetup.new
			@doc_class = @ds.document_class_type('consult')
			@doc_class.save
			@tefrench = @ds.create_patient
			@visit = @ds.create_visit('tfv1234', @tefrench)
			@doc_type = DocumentType.find @doc_class.document_types[0][:id]
			@type_info = {id: @doc_type.id, code: @doc_type.code, class_id: @doc_type.document_class[:id],
			              class_code: @doc_type.document_class[:code]}

			@clin_doc = @ds.clinical_document(@tefrench, @visit, @type_info)
			#ClinicalDocument.new(patient: @tefrench, type_id: @doc_class.document_types[0][:id])
			@doc_version = @ds.document_version(@clin_doc, nil)
			@cdoc = @ds.clinical_document(@tefrench, @visit, @type_info)

		 end

		# it 'Practice wanting mail should have a primary delivery_class_id of mail.id' do
		# 	#ds = DeliverySetup.new
		# 	prac = @ds.create_mail_practice
		# 	expect(prac.primary_device[:id]).to eq MailDeliveryClass.default_device.id
		# end

		# it "should queue nightly mail for a practice with no profile and primary delivery = Mail" do
		# 	#dm = DeliveryManager.new(@cdoc)
		# 	#
		# 	prac = @ds.create_mail_practice
		# 	of = @ds.create_fax_device(prac.summary)
		# 	prac.add_device(of, false)
		# 	raw = RawName.lookup(prac.name)
		# 	raw.link(prac.name, prac.id, :practice)
		# 	dp = DeliveryProfile.add_profile(@type_info, prac.primary_device, prac.summary, [:cc, :generating])
		# 	dp.save
		#
		# 	#cdoc = @ds.clinical_document(1, 2, @doc_type)
		# 	#prac.deliver_document(@cdoc.id, :cc)
		# end
		#
		#
		# it 'should find profiles for practice' do
		# 	#dm = DeliveryManager.new(@cdoc)
		# 	#
		# 	prac = @ds.create_mail_practice
		# 	raw = RawName.lookup(prac.name)
		# 	of = @ds.create_fax_device(prac.summary)
		#
		# 	prac.add_device(of, false)
		# 	raw.link(prac.name, prac.id, :practice)
		# 	# doc_info = {}
		# 	# doc_info[:class_id] = @doc_type.document_class[:id]
		# 	# doc_info[:class_code] =  @doc_type.document_class[:code]
		# 	# doc_info[:id] = @doc_type.id
		# 	# doc_info[:code] = @doc_type.code
		#
		# 	dp = DeliveryProfile.add_profile(@type_info, prac.primary_device, prac.summary, ['cc', 'generating'])
		# 	dp.save
		#
		# 	dps = DeliveryProfile.by_doc_type(@type_info, prac.summary) #, ['cc'])
		# 	expect(dps.count).to eql 1
		# 	expect(dps[0].id).to eql dp.id
		# 	expect(dps[0].device[:id]).to eql prac.primary_device[:id]
		# 	#prac.deliver_document(@cdoc.id, :cc)
		#
		# end
		#
		# it "should deliver via mail if practice is in rawnames and setup with no primary device" do
		# 	raw = RawName.lookup(@prac.name)
		# 	dm = DeliveryManager.new(@cdoc)
		# 	dm.deliver(raw, 'cc')
		# end
		#
		# it "should not delivery anything if practice setup and primary set to none" do
		# 	@ds = DeliverySetup.new()
		# 	prac = @ds.create_none_practice()
		# 	dc = @ds.document_class_type('trans')
		# 	dt = DocumentType.by_class_id(dc.id).first
		# 	#dp = delivery_profile(dc, dt, del_class, del_dev, uuid)
		# 	pat =  FactoryBot.create(:t_french)
		# 	v = FactoryBot.build(:t_french_visit)
		# 	v.patient_id = pat.id
		# 	v.save
		# 	raw = RawName.lookup(prac.name)
		# 	cdoc = @ds.clinical_document(pat.id, v.id, dt.id)
		# 	DeliveryRequest.request_delivery(raw, cdoc.id)
		# 	expect(DeliveryRequest.count).to eql 0
		# end
		#
		# it "should queue a fax for a practice with no profile and primary fax to 855-810-0810" do
		# 	@ds = DeliverySetup.new()
		# 	prac = @ds.create_fax_practice()
		# 	dc = @ds.document_class_type('trans')
		# 	dt = DocumentType.by_class_id(dc.id).first
		# 	#dp = delivery_profile(dc, dt, del_class, del_dev, uuid)
		# 	pat =  FactoryBot.create(:t_french)
		# 	v = FactoryBot.build(:t_french_visit)
		# 	v.patient_id = pat.id
		# 	v.save
		# 	dm = DeliveryManager.new(@cdoc, @doc_class, @doc_type)
		# 	raw = RawName.lookup(prac.name)
		# 	cdoc = @ds.clinical_document(pat.id, v.id, dt.id)
		#
		# 	DeliveryRequest.request_delivery(raw, cdoc.id)
		# 	expect(DeliveryRequest.count).to eql 1
		# 	ndr = DeliveryRequest.first
		# 	expect(ndr.prac_uuid).to eql prac.uuid
		# 	expect(ndr.command).to eql '855-810-0810'
		# end
	end

	# describe "Practice has setup delivery profiles" do
	# 	before :each do
	# 		@ds = DeliverySetup.new()
	# 		@prac = @ds.create_mail_practice()
	# 		@doc_class = @ds.document_class_type('trans')
	# 		@doc_type = DocumentType.by_class_id(@doc_class.id).first
	# 		#dp = delivery_profile(dc, dt, del_class, del_dev, uuid)
	# 		@pat =  FactoryBot.build(:t_french)
	# 		@pat.save
	# 		v = FactoryBot.build(:t_french_visit)
	# 		v.patient_id = @pat.id
	# 		v.save
	# 		@cdoc = @ds.clinical_document(@pat.id, v.id, @doc_type)
	# 		@ofax = FaxDevice.new
	# 		@ofax.delivery_class_id = FaxClass.default.id
	# 		@ofax.delivery_class_name = FaxClass.default.name
	# 		@ofax.owner = @prac
	# 		@ofax.name = "Office Fax"
	# 		@ofax.description = "Office Fax"
	# 		@ofax.number = "855-810-0810"
	# 		@ofax.save
	# 	end
	# 	#
	# 	# it "should deliver to a device specified in the Delivery profile not the primary", focus: true do
	# 	# 	dm = DeliveryManager.new(@cdoc, @doc_class, @doc_type)
	# 	# 	#dr = DeliveryRequest.new()
	# 	#
	# 	# 	raw = RawName.lookup(@prac.name)
	# 	# 	@ds.delivery_profile(@doc_class, @doc_type, DeliveryClass.fax, @ofax, @prac.uuid)
	# 	# 	dm.deliver(raw, "cc")
	# 	# 	#dr.request_delivery(raw, @cdoc.id)
	# 	# 	expect(dm.queue_count).to eql 1
	# 	# 	expect(dm.queue['fax-855-810-0810']['command']).to eql '855-810-0810'
	# 	#
	# 	# end
	# end
	#
	# #describe "Physician in practice should default to Practice "

end


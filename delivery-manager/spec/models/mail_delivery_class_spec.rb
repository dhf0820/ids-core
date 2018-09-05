require 'spec_helper'
require './models/mail_delivery_class'
require './spec/factories/mail_class'
require './spec/factories/mail_delivery'


RSpec.describe MailDeliveryClass, type: :model do
	before :each do

	end

	it "should create a complete Mail Default delivery" do
		mc = MailDeliveryClass.new()
		expect(mc.name).to eql 'Mail'
		expect(mc.description).to eql "Daily Mail Batch"
		expect(mc.devices.count).to eql 1
		expect(mc.devices[0][:name]).to eql 'Mail'
		expect(MailDeliveryClass.default.name).to eql 'Mail'
	end

	it "should create only one default mail delivery" do
		dmail = MailDeliveryClass.default
		expect(MailDeliveryClass.default.id).to eql dmail.id
	end

	it 'Should not create other Mail Delivery Classes'  do
		m1 = MailDeliveryClass.new
		expect{MailDeliveryClass.new}.to raise_error('Mail Delivery class is already set up. Use it.')
	end

	it "Should not create new Class if default is already created" do
		md = MailDeliveryClass.default
		expect{MailDeliveryClass.new}.to raise_error('Mail Delivery class is already set up. Use it.')
	end


	# it 'should add a new device to its managed devices' do
	# 	mc = MailDeliveryClass.new()
	# 	md = MailDelivery.new()
	# 	mc.add_device(md)
	# 	expect(mc.devices.count).to eql 2    #one is added initialy becuse it is one of the default
	# end

	# describe 'delivery queueing' do
	# 	before :context do
	# 		@ds = DeliverySetup.new
	# 		@doc_class = @ds.document_class_type('consult')
	# 		@doc_class.save
	# 		@tefrench = Patient.new(name: 'Theresa French', mrn: 'te1015')
	# 		@tefrench.save
	# 		@clin_doc = ClinicalDocument.new(patient_id: @tefrench, type_id: @doc_class.document_types[0][:id])
	# 		@clin_doc.save
	# 		@prac = @ds.create_mail_practice
	# 		@raw = RawName.lookup(@prac.full_name)
	# 	end
	#
	# 	it 'should queue a document for delivery to nightly print' do
	#
	# 	end



end
#require 'rails_helper'
require 'spec_helper'
require './models/practice'

require './models/fax_class'
require './models/fax_device'
require './spec/utilities/delivery_setup'
#require './spec/factories/practice'
#require './spec/factories/delivery_class'



RSpec.describe Practice, type: :modele, focus: true do


	before :context do
		@ds = DeliverySetup.new
	end

	it 'should add a device' do
		fe = Practice.new()
		fe.name = 'Enyedi-French Clinic'
		#fe = FactoryBot.build(:french_enyedi)exi
		fe.save
	end

	# it 'should create a new practice with primary delivery_class of MAIL' do
	# 	fe = Practice.new(name: 'Enyedi-French Clinic')
	# 	expect(fe.primary_device[:id]).to eql MailDeliveryClass.default_device.id
	# end



	it 'should be able to add a custom primarydelivery device of class FAX', focus: true do
		ef = Practice.new
		ef.name = 'Enyedi-French Clinic'
		fc = FaxClass.default
		of = FaxDevice.new
		#of.prac_uuid = @fe.uuid
		of.name = "Office Fax"
		of.description = "Office Fax"
		of.fax_number =   '855-810-0810‬'
		fc.add_device(of)
		of.save
		ef.add_device(of, true)
		ef.remove_device MailDeliveryClass.device
		#ef.set_primary(of) 		;
		ef.save

		fe = Practice.find(ef.id)
		expect(fe.primary_device[:device_id]).to eql of.id.to_s

		expect(fe.devices.count).to eql 2    # primary fax other mail
	end

	# it 'should be able to create a custom delivery device of class FAX as additional delivery device' do
	# 	ef = Practice.new(name: 'Enyedi-French Clinic')
	# 	fc = FaxClass.default
	# 	of = FaxDevice.new
	# 	#of.prac_uuid = @fe.uuid
	# 	of.name = "Office Fax"
	# 	of.description = "Office Fax"
	# 	of.number =   '855-810-0810‬'
	# 	fc.add_device(of)
	# 	of.save
	# 	ef.add_device(of, false)
	# 	#ef.set_primary(of)                                                                  ;
	# 	ef.save
	# 	fe = Practice.find(ef.id)
	# 	expect(fe.devices.count).to eql 2
	# 	expect(fe.primary_device[:id]).to eql MailDeliveryClass.default_device.id
	# end

	it 'should create a summary hash' do
		ef = Practice.new
		ef.name =  'Enyedi-French Clinic'
		recipient = ef.summary
		expect(recipient[:ids_id]).to eql ef.id.to_s
		expect(recipient[:name]).to eql ef.name
		expect(recipient[:context]).to eql ef.owner_context
	end

end

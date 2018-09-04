require 'spec_helper'
require './models/fax_class'
require './spec/factories/fax_class'
require './spec/factories/fax_device'
require './models/ids_error'


RSpec.describe FaxClass, type: :model, focus: true do
	before :each do

	end

	it 'should always use the default FaxClass' do
		fax = FaxClass.default
		fax1 = FaxClass.default

		expect(fax.id).to eql(fax1.id)
	end

	it 'should not create a new fax class' do
		fc = FaxClass.new
		fc.save
		expect{FaxClass.new}.to raise_error(IdsError) #(name: 'Fax', description: 'Efax Delivery')
	end

	it 'should allow new devices to be managed' do
		fc = FaxClass.new#(name: 'EFax', description: 'Efax Delivery')
		fc.save

		delv = FactoryBot.build(:fax_dev)
		delv.save
		fc.add_device(delv)
		expect(fc.devices.count).to eql 1
		expect(fc.devices[0][:name]).to eql 'FAX'
	end

	it 'should be able to add a document to the DeliveryRequest for a managed device'

	it 'should know how to communicate with the fax delivery server'
end
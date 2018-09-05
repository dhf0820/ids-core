require 'spec_helper'
require './models/no_delivery_class'
# require './spec/factories/none_class'
# require './spec/factories/none_delivery'


RSpec.describe NoDeliveryClass, type: :model do
	before :each do

	end


	it "should crerate a complete No delivery class and delivery" do
		nc = NoDeliveryClass.new #({name: 'None', description: "No delivery"})
		expect(nc.name).to eql 'None'
		expect(nc.description).to eql "No delivery this type/class of documents"
		expect(nc.devices.count).to eql 1
		expect(nc.devices[0][:name]).to eql 'None'
	end

	it "should create only one default No Delivery Class" do
		ndc = NoDeliveryClass.new
		expect{NoDeliveryClass.new}.to raise_error('No Delivery class is already set up. Use it.')
		# dnone = NoneClass.default
		# expect(dnone.name).to eql 'None'
		# expect(NoneClass.default.id).to eql dnone.id
	end
end
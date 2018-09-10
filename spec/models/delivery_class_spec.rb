#require 'rails_helper'
require 'spec_helper'
require './models/delivery_class'
require './spec/factories/delivery_class'
require './models/updateable'
require './models/ids_error'

# Delivery class does not allow any direct creation there are specific delivery classes that inherit from this oine.
RSpec.describe DeliveryClass, type: :model do
	#let(:mail)  {FactoryBot.build(:mail)}
	before :each do

	end

	# it 'should find DeliveryClass by id', focus: true do
	# 	mail = DeliveryClass.new(name: 'MAIL', description: 'Delivery daily via US MAIL', status: {state: :active})
	# 	expect(DeliveryClass.find(mail.id).id).to eql(mail.id)
	# end
end
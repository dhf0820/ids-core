
require 'rspec'
require 'spec_helper'

require './spec/utilities/delivery_setup'
require './models/ids_error'
require './models/app_environment'
require './models/customer_environment'
require './models/remote_repository'

# Delivery class does not allow any direct creation there are specific delivery classes that inherit from this oine.
RSpec.describe RemoteRepository, type: :model do
	#let(:mail)  {FactoryBot.build(:mail)}
	before :each do
		@ds = DeliverySetup.new
		@ds.create_environment
		#@ds.create_rabbit
	end

	after :each do
		puts "After each"
	end

	it 'should find patient by mrn' do
		#doc = $remote.
		pat = $remote.patient_by_mrn('654321')
		expect(pat.mrn).to eql '654321'
	end


	it 'should raise error if remote patient does not exist'do
		#expect{$remote.patient_by_mrn('0000')}.to raise_exception(IdsError, 'Patien mrn 0000 not found')
		expect($remote.patient_by_mrn('0000')).to be_nil
	end

	# it 'should create  new patient', focus: true do
	# 	pat = Patient.new
	#
	# end
	# it 'should find DeliveryClass by id', focus: true do
	# 	mail = DeliveryClass.new(name: 'MAIL', description: 'Delivery daily via US MAIL', status: {state: :active})
	# 	expect(DeliveryClass.find(mail.id).id).to eql(mail.id)
	# end
end
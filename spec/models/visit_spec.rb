#require 'rails_helper'
require 'spec_helper'
require './models/patient'


require './spec/utilities/test_setup'
require './models/ids_error'
require './models/app_environment'
require './models/customer_environment'
require './models/remote_repository'

RSpec.describe Visit, type: :model do




	before :each do
		@ts = TestSetup.new
		@ts.create_environment
	end

	it 'should find patient by mrn' do
		pat = Patient.by_mrn('te1015')
		expect(pat.mrn).to eql 'te1015'
		expect(pat.remote_id).to eql('384')
	end

	it 'should not find patient by mrn' do
		pat = Patient.by_mrn('89988')
		expect(pat).to be_nil
	end
#
	it 'should create a new patient' do
		pat = Patient.new

		pat.name = 'French, Theresa'
		pat.first_name = 'Theresa'
		pat.middle_name = 'E'
		pat.last_name = 'French'
		pat.sex = 'F'
		pat.marital_status = 'M'
		pat.mrn = 'tf1234'
		pat.birth_date = Date.strptime('10/15/1957', '%m/%d/%Y')
		pat.ssn = '555-12-6789'
		pat.save
		pat.update_remote
		expect(pat.remote_id).to_not be_nil
	end
end

#require 'rails_helper'
require 'spec_helper'
require './models/patient'


require './spec/utilities/test_setup'
require './models/ids_error'
require './models/app_environment'
require './models/customer_environment'
require './models/remote_repository'

RSpec.describe Patient, type: :model do




	before :each do
		@ts = TestSetup.new
		@ts.create_environment
	end

	it 'should find patient by mrn'do
		pat = Patient.by_mrn('899888')
		expect(pat.mrn).to eql '899888'
		expect(pat.remote_id).to eql('384')
	end

	it 'should not find patient by mrn' do
		pat = Patient.by_mrn('89988')
		expect(pat).to be_nil
	end
#
	# it 'should update an existing patient' do
	# 	pat = Patient.new
	# 	pat.name = 'French, Theresa'
	# 	pat.first_name = 'Theresa'
	# 	pat.middle_name = ''
	# 	pat.last_name = 'French'
	# 	pat.sex = 'F'
	# 	pat.marital_status = 'M'
	# 	pat.mrn = 'tf1015'
	# 	pat.birth_date = Date.strptime('10/15/1957', '%m/%d/%Y')
	# 	pat.ssn = '123-12-6789'
	# 	pat.save
	# 	#pat.update_remote
	# 	expect(pat.remote_id).to_not be_nil
	# 	pat.middle_name = 'E'
	# 	pat.save_with_remote

	# 	pat = $remote.patient_by_mrn('tf1015')
	# 	expect(pat.last_name).to eql 'French'
	# 	expect(pat.middle_name).to eql 'E'
	# end


	# it 'should create a new patient' do
	# 	pat = Patient.new
	# 	pat.name = 'LaCour, Lacey A'
	# 	pat.first_name = 'Lacey'
	# 	pat.middle_name = 'A.'
	# 	pat.last_name = 'LaCour'
	# 	#pat.sex = 'F'
	# 	#pat.marital_status = 'M'
	# 	pat.mrn = 'll0819'
	# 	#pat.birth_date = Date.strptime('08/19/1981', '%m/%d/%Y')
	# 	#pat.ssn = '123-12-1111'
	# 	pat.save_with_remote
	# 	#pat.update_remote
	# 	expect(pat.remote_id).to_not be_nil
	# end


end

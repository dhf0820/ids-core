#require 'rails_helper'
require 'spec_helper'
require './models/patient'


require './spec/utilities/delivery_setup'
require './models/ids_error'
require './models/app_environment'
require './models/customer_environment'
require './models/remote_repository'

RSpec.describe Patient, type: :model do




	before :each do
		@ds = DeliverySetup.new
		@ds.create_environment
	end

	it 'should find patient by mrn' do
		pat = Patient.by_mrn('654321')
		expect(pat.mrn).to eql '654321'
		expect(pat.remote_id).to eql('33')
	end

	it 'should not find patient by mrn' do
		pat = Patient.by_mrn('89988')
		expect(pat).to be_nil
	end

	it 'should create a new patient', focus: true do
		pat = Patient.new

		pat.name = 'French, Theresa'
		pat.first_name = 'Theresa'
		pat.middle_name = 'M'
		pat.last_name = 'French'
		pat.sex = 'F'
		pat.marital_status = 'M'
		pat.mrn = 'tf1234'
		pat.birth_date = Date.strptime('10/15/1957', '%m/%d/%Y')
		pat.ssn = '555-12-6781'
		pat.save
		rpat = pat.update_remote
		expect(rpat.remote_id).to eql '10'
	end

	it "should update a patient" do
		pat = Patient.by_mrn('tf1234')
		expect(pat.mrn).to eql 'tf1234'
		pat.middle_name = 'M'
		pat.save
		pat.update_remote
		# pat1 = $remote.patient_by_mrn(pat.mrn)
		# expect(pat1.middle_name).to eql 'M'
	end
  # it 'should find physician by uuid' do
  #   french =   FactoryBot.build(:phy_french)
  #   french.save
  #   uuid = french.id
  #   expect(Physician.find(uuid).id).to eql(uuid)
  # end
  #
  # it 'should have a default primary_delivery_class of mail'  do
	#   phy = Physician.new()
	#   expect(phy.primary_device[:name]).to eql 'Mail'
  # end
  #
  # it "should create a new physician with defaults" do
	#   args = {}
	#   name = args[:name] = {}
	#   name[:first] = 'Theresa'
	#   name[:last] = 'French'
	#   phy = Physician.new(args)
	#   expect(phy.name[:first]).to eql 'Theresa'
	#   expect(phy.name[:last]).to eql 'French'
	#   expect(phy.devices.count).to eql 1
	#   expect(phy.primary_device[:name]).to eql 'Mail'
  # end




  # it 'should find physician by first and last name' do
  #   phy_french.save
  #   #phy = Physician.find_by_names('Donald', 'French')
  #   fk =      Physician.generate_phonetic 'Donald'
  #   lk =  Physician.generate_phonetic 'French'
  #   phy = Physician.find_by_names(phy_french.first_name, phy_french.last_name)
  #   p =   Physician.where("ln_primary_phonetics = :ln_key and fn_primary_phonetics = :fn_key", {ln_key: lk[0], fn_key: fk[0]})
  #   expect(phy.count).to eql 1
  #   expect(phy[0].id).to eql phy_french.id
  # end

  # it 'should remove MD from last, MD, first for a physician'do
  #   phy_french.name = 'French, MD, Donald'
  #   expect(phy_french.raw_name).to eql 'French, Donald'
  # end

  # it 'should remove MD from First last, MD for a physician'do
  #   #expect(phy_french.raw_name).to eql 'French, Donald'
  #   phy_french.name = 'Donald French, MD'
  #   expect(phy_french.raw_name).to eql 'Donald French'
  # end

  # it 'should generate aliases' do
  #   phy_french.save
  #   aliases = PhysicianAlias.where('physician_id = ?', phy_french.id)
  #   expect(aliases.count).to eql 2
  #   expect(aliases[0].name).to eql "DONALDHFRENCH"
  #   expect(aliases[1].name).to eql "FRENCHDONALDH"
  # end
  #
  # it 'should find physician using alias' do
  #   phy_french.save
  #   expect(Physician.find_for_alias('Donald H French')).to eql phy_french
  # end

end

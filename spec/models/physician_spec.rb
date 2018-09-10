#require 'rails_helper'
require 'spec_helper'
require './models/physician'
require './spec/factories/physician'


RSpec.describe Physician, type: :model do

  let(:french)  {FactoryBot.build(:phy_french)}


  before :each do

  end

  it 'should find physician by uuid' do
	  args = {}
	  name = args[:name] = {}
	  name[:first] = 'Theresa'
	  name[:last] = 'French'
	  phy = Physician.new(args)
	  phy.save
	  uuid = phy.id
    expect(Physician.find(uuid).id).to eql(uuid)
  end

  it 'should have a default primary_delivery_class of mail'  do
	  phy = Physician.new()
	  expect(phy.primary_device[:device_name]).to eql 'Mail'
  end

  it "should create a new physician with defaults" do
	  args = {}
	  name = args[:name] = {}
	  name[:first] = 'Theresa'
	  name[:last] = 'French'
	  phy = Physician.new(args)
	  phy.save
	  expect(phy.name[:first]).to eql 'Theresa'
	  expect(phy.name[:last]).to eql 'French'
	  expect(phy.devices.count).to eql 1

	  expect(phy.primary_device[:device_name]).to eql 'Mail'
  end




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

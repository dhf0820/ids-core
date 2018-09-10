require 'spec_helper'
require '../sys_models/chart_archive_class'
require '../sys_models/ids_error'
require './spec/utilities/test_setup'



RSpec.describe ChartArchiveClass, type: :mode do
	before :each do
    TestSetup.new
	end

  it 'should always use the default ChartArchiveClass', focus: true do
    puts "test 1"
		cac1 = ChartArchiveClass.default
    cac2 = ChartArchiveClass.default
    expect(ChartArchiveClass.count).to eql 1 
		expect(cac1.id).to eql(cac1.id)
	end

	it 'should not create a new ChartArchive Delivery Class if one there' do
	  # cac = ChartArchiveClass.new
    # cad.save
		expect{ChartArchiveClass.new}.to raise_error(IdsError) 
	end

  it 'should create a single ChartArchive Deliver device' do
    puts 'test 2'
    cac = ChartArchiveClass.default 
    cad = ChartArchiveClass.default_device
    expect(ChartArchiveDelivery.count).to eql 1
  end

  

end
require 'spec_helper'
require './models/chart_archive_class'
require '../sys_models/ids_error'


RSpec.describe ChartArchiveClass, type: :mode do
	before :each do

	end

	it 'should always use the default ChartArchiveClass' do
		fax = ChartArchiveClass.default
		fax1 = ChartArchiveClass.default
    expect(ChartArchiveClass.count).to eql 1
		expect(fax.id).to eql(fax1.id)
	end

	it 'should not create a new fax class' do
		fc = ChartArchiveClass.new
    fc.save
		expect{ChartArchiveClass.new}.to raise_error(IdsError) 
	end

  it 'should create a single ChartArchive Deliver device' do
    fc = ChartArchiveClass.default
    cad = ChartArchiveClass.default_device
    expect(ChartArchiveDelivery.count).to eql 1
  end

  

end
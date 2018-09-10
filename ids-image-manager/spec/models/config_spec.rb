#require File.dirname(__FILE__) + '/../../spec_helper.rb'
#config_path = File.dirname(__FILE__) + "fixtures/test_reader.yml"
#env_name = 'READER_TEST'
#include IDSReader
require './spec/spec_helper'
require './spec/utilities/test_setup'



describe Config, focus:true do
  before :each do
		@ts = TestSetup.new


    @confog = Config.new
		options = {}

		#   Reader.new(config)
    #Reader.new('reader')
	end

  describe "initialization" do

    it "should return the current configuration" do
	    expect(Config.active.process).to eql 'image_manager'
    end
  end

  describe 'access methods' do
  
    it "should report processor name" do
      expect(Config.active.processor_name).to eql 'image_manager' 
    end

    it 'should have a unknown_name' do
      expect(Config.active.unknown_queue_name).to eql 'unknown'
    end

    it "should always return the same ChartArchiveClass" do
      cac = Config.active.chart_archive_class
      expect(cac).to_not be_nil
      expect(Config.active.chart_archive_class).to eql cac
    end

    it "should alwasy return the same ChartArchiveDevice" do
      cad = Config.active.chart_archive_device
      expect(cad).to_not be_nil
      expect(Config.active.chart_archive_device).to eql cad
    end
  end




end


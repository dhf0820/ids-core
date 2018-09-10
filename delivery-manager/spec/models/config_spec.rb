#require File.dirname(__FILE__) + '/../../spec_helper.rb'
#config_path = File.dirname(__FILE__) + "fixtures/test_reader.yml"
#env_name = 'READER_TEST'
#include IDSReader

require './spec/utilities/test_setup'

require '../sys_lib/vs_log'

describe Config, focus: true do
  before :each do
		@ts = TestSetup.new


    @config = Config.new
		options = {}

	end

  describe "initialization" do

    it "should return the current configuration" do
	    expect(Config.active.process).to eql 'dm_test'
      #expect{Reader.new()}.to_not raise_error  #(InvalidConfiguration)
    end


  end

  describe 'access methods' do
  
    it "should report processor name" do
      expect(Config.active.processor_name).to eql 'dm_test' 
    end

    it "Should return the in_queue" do
      expect(@config.in_queue).to_not be_nil
    end

    it 'SHould have a in_queue_name' do 
      expect(@config.in_queue_name).to eql 'test_dispatch'
    end


  end


end


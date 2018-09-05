#require File.dirname(__FILE__) + '/../../spec_helper.rb'
#config_path = File.dirname(__FILE__) + "fixtures/test_reader.yml"
#env_name = 'READER_TEST'
#include IDSReader
require './models/inbound_queue'
require './models/next_queue'
require './spec/utilities/test_setup'



describe Config do
	before :each do
		@ts = TestSetup.new
		@ts.create_environment
		#@ts.create_rabbit
		@ts.create_data_dictionary
		@ts.create_definitions

		options = {}
		options[:reader] = 'reader'
		config = Config.new()
		#   Reader.new(config)
		#Reader.new('reader')
	end

  describe "initialization" do

    it "should return the current configuration", focus: true do
	    expect(Config.active.process).to eql 'reader'
      #expect{Reader.new()}.to_not raise_error  #(InvalidConfiguration)
    end


	  it "should create the DataElements hash" do
		  expect(DataElements.element(:dob)).to_not be_nil
	  end

	  it "should create descriptors_defined" do
		  expect(Config.descriptor_keys[0]).to eql 'consult_a55'

	  end

	  it "should initialize queues" do
		#binding.pry
	  end

    it 'should have more document_defs than used' do
		expect(DocumentDef.count).to be > Config.descriptor_keys.count
    end

	it 'should load all document Recognizers' do
		expect(Config.recognizers.count).to eql 3
		expect(Config.recognizers[:consult_a55].document_type).to eql 'ConsultA55'
	end

  end

  describe 'access methods' do
  
    it "should report processor name" do
      expect(Config.active.processor_name).to eql 'reader' 
    end


    it 'should return an array of all recognizers this reader has' do
	    expect(Config.recognizers.count).to eql 3
    end

    it 'should return the specified recognizer' do
	    expect(Config.recognizer(:consult_a55).name).to eql 'consult_a55'
    end
    #
    # it "should report base path" do
    #   @config.base_path.should == "./spec/fixtures/processors/test_reader/test/"
    # end
    #
    # it "should report descriptor path" do
    #   @config.descriptor_path.should == "./spec/fixtures/processors/test_reader/test/descriptors/"
    # end
    #
    # it "should report pending path" do
    #   @config.pending_path.should == './spec/fixtures/processors/test_reader/test/pending/'
    # end
    #
    # it "should report archive path" do
    #   @config.archive_path.should == '/tmp/archive/'
    # end
    #
    # it "should report output path" do
    #   @config.output_path.should == './spec/fixtures/processors/test_reader/test/output/'
    # end
    #
    # it "should return the system path" do
    #   @config.system_path.should ==@env_name
    # end
    #
    # it "should report log path" do
    #   @config.log_file.should == './spec/fixtures/processors/test_reader/test/logs/test.log'
    # end
    #
    # it "should report tmp path" do
    #   @config.tmp_path.should == './spec/fixtures/processors/test_reader/test/tmp/'
    # end
    #
    # it 'should report a full tmp path' do
    #   @config.add('tmp_path', '/tmp/')
    #   @config.tmp_path.should == '/tmp/'
    #   @config.add('tmp_path', '~/tmp/')
    #   @config.tmp_path.should == '~/tmp/'
    # end
    #
    # it "should report queue name" do
    #   @config.queue_name.should == 'queue_test'
    # end
    #
    # it "should return the path of the config file being used" do
    #   @config.config_path.should == './spec/fixtures/processors/test_reader/config/'
    # end
    #
    # it "should return the current runtime mode" do
    #   @config.runtime_mode.should == 'test'
    # end
    #
    #
    # it "should allow setting and retrieving of the global descriptors" do
    #   @config.descriptors = 'descriptor_classes'
    #   @config.descriptors.should == 'descriptor_classes'
    # end
    #
    #
    # it "should be able to add new config value" do
    #   @config.add(:newkey, "new Value")
    #   @config.get(:newkey).should == 'new Value'
    # end
    #
    # it "should return nil on invalid get" do
    #   expect(Config.get(:junk)).to be_nil
    # end
  end


end


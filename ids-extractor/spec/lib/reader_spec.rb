#require File.dirname(__FILE__) + '/../../spec_helper.rb'
require './spec/utilities/test_setup'
require './models/config.rb'
# Time to add your specs!
# http://rspec.info/
describe Reader, focus: true do

	before :each do

		@ts = TestSetup.new
		@ts.create_environment
		@ts.create_rabbit
		@ts.create_data_dictionary
		@ts.create_definitions

		@config = Config.new()
		@reader = Reader.new(@config)
	end

  # before :all do
  #   #ENV['READER'] = 'reader'
  #   #@env_name = "./spec/fixtures/processors/test_reader/"
	#   options = {}
	#   options[:reader] = 'reader'
	#   config = Config.new(options)
	#   @reader = Reader.new(config)
  # end



  it "Should initialize" do
    expect(@reader).to_not be nil
  end

	# it "Should return the current configration" do
	# 	expect(@reader.config('process')).to eql 'reader'
	# end

  # it 'should provide a global $reader variable' do
  #   expect($reader).to eql @reader
  # end
  #
  # it 'should provide a global configuration variable' do
  #   expect($configuration).to_not be nil
  # end
  #
  # it 'should provide a method on @reader to get the configuration' do
  #   expect(@reader.configuration).to eql $configuration
  # end
  #
  # it "should automatically create a processor" do
  #   expect(@reader.processor.class.name).to eql "ReportReader::Processor"
  # end
  #
  # it 'should return the processor name' do
  #   expect(@reader.processor_name).to eql "TestDocumentProcessor"
  # end
  #
  # it 'should return the inbound queue name' do
  #   expect(@reader.queue_name).to eql 'queue_test'
  # end
  #
  # it 'should return to outbound queue name' do
  #   expect(@reader.queue_to).to eql 'ihids_test'
  # end
  #
  # it 'should return the runtime mode (test/live) ' do
  #   expect(@reader.mode).to eql 'test'
  # end
  #
  # it 'should change the mode' do
  #   @reader.mode = 'live'
  #   expect(@reader.mode).to eql 'live'
  # end
  #
  # it 'should return proper queue names' do
  #   @reader.mode = 'live'
  #   expect(@reader.queue_name).to eql 'queue'
  #   expect(@reader.queue_to).to eql 'ihids'
  # end


end

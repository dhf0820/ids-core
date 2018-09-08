require './spec/utilities/test_setup'
require './models/config.rb'
require 'logging'

describe Processor do

  before :each do

    @ts = TestSetup.new
    @ts.create_environment
    @ts.create_data_dictionary
    @ts.create_definitions

    @config = Config.new()
    @reader = Reader.new()

    @logger = Logging::Logger["processor_test"]
    #@logger.add_appenders  Logging.appenders.stdout #, Logging.appenders.file('example.log')
    #@logger.info "   @@@ This is a test"
    @processor = @reader.processor
  end
  
  it "should log properly" do
    #expect(@logger.debug( "should fail")).to be false
    @logger.level=:debug
    expect(@logger.debug("This is a Debug Message")).to be true
    #expect(@log_output.readline).to eql 'Test'
  end
#
  it "should list all valid descriptors" do
      expect(@processor.descriptor_keys).to eql ['consult_a55', 'mercy_lab', 'sample_descriptor']
    #expect(@processor.descriptors).to eql [ConsultA55, MercyLab]
  end

  it "should have recognizers for each descriptor" do
	  expect(@processor.recognizer(:consult_a55).recognizer).to eql ConsultA55
	  expect(@processor.recognizer(:sample_descriptor).recognizer).to eql SampleDescriptor
  end


  it 'should process all reports and identify them correctly for consult' do
    @processor.document_path = "./spec/fixtures/processors/test_reader/test/test_data/consult.pdf.txt"
    expect(@processor.document.process_document).to eql 1
    expect(@processor.process_document).to eql 1
  end

  it "should process a provided file immediately test 1" do
    #expect(@processor.process_file("./spec/fixtures/processors/test_reader/test/test_data/test1.txt")).to eql 1
	  expect(@processor.process_file("./samples/doc-lab1.pdf.txt")).to eql 1
  end
  #
  # it "should process a buffer of text immetiately" do
  #
  #   buffer = File.read("./spec/fixtures/processors/test_reader/test/test_data/consult.pdf.txt")
  #   expect(@processor.process_buffer(buffer).reports.count).to eql 1
  # end
  #
  # it "should find descriptor information 56" do
  #   expect(@processor.descriptor_list).to eql  [ 'consult_a55', 'test_er']
  #
  # end
  #
  #
  # it "should accept and process a document as a parameter" do
  #   expect(@processor.process_document("./spec/fixtures/processors/test_reader/test/test_data/test1.txt")).to eql 1
  # end


end
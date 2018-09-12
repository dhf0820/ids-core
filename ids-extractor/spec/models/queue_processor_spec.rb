require './spec/utilities/test_setup'
require './models/config.rb'
require 'logging'
require './models/queue_processor'

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
    @q_processor = QueueProcessor.new(@reader)
  end
  
 
  it "should process a provided file immediately test 1" do
    #expect(@processor.process_file("./spec/fixtures/processors/test_reader/test/test_data/test1.txt")).to eql 1
	  expect(@processor.process_file("./samples/doc-lab1.pdf.txt")).to eql 1
  end
  
  it "should process a buffer of text immetiately", focus: true do
    #buffer = File.read("./spec/fixtures/processors/test_reader/test/test_data/consult.pdf.txt")
    x = @q_processor.process_file("./samples/doc-lab1.pdf.txt")
    binding.pry
    #expect(@q_processor.process_buffer(buffer).reports.count).to eql 1
  end
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
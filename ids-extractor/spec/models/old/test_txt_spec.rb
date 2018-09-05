#require File.dirname(__FILE__) + '/../../spec_helper.rb'

#config_path = File.dirname(__FILE__) + "/../../fixtures/test_reader.yml"


describe "test.txt" do
=begin

  before :each do

    @env_name = "./spec/fixtures/processors/test_reader/"
  #  @config =IDSReader::Config.configure_environment(@env_name)
    @reader =IDSReader.new(@env_name)
    @config = $configuration
    @processor = @reader.processor

    #@processor = @config.create_processor

    @document = @processor.process("#{@config.base_path}/test_data/test.txt")   #test.txt")

    #@document = @processor.document_path("#{@config.base_path}/test_data/test.txt")
  end
  
  it 'should have 2 reports' do
    #@document = @processor.document_path("#{@config.base_path}/test_data/test.txt")
    expect(@document.raw_reports.count).to eql 2
  end

  it 'should have 1 report' do
    #@document = @processor.document_path("#{@config.base_path}/test_data/test.txt")
    expect(@document.reports.count).to eql 1
  end

  it 'should have 1 unknown report' do
    #@document = @processor.document_path("#{@config.base_path}/test_data/test.txt")
    expect(@document.unknown_reports.count).to eql 1
  end

  it 'should determine the first report to be a HealthPhysicalA53' do
    expect(@document.report(0).report_type.class).to eql HealthPhysicalA53

  end

  it 'should determine the second report to be a Nil' do
    expect{@document.report(1)}.to raise_error(ArgumentError)
  end  
  
  it "should process all reports and identify them correctly" do
    expect(@document.reports_count).to eql 1
  end

  it 'should create one unknown file' do
    expect(@document.unknown_reports.count).to eql 1
    fn = @document.unknown_file_name(0)
    File.delete(fn) if(File.exists? fn)
    f = @document.save_unknown_report(0)

    expect(File.exists? fn).to be true
    f = open(@document.unknown_file_name(0), "r")
    expect(f.size).to eql 1794 
  end


  it 'should create one recognized dfile document' do
    fn = @document.save_file_name(0, :dfile)
    File.delete(fn) if(File.exists? fn)
    expect(@document.save_report(0, :dfile)).to_not be nil
    expect(File.exists? fn).to be true
    f = open(fn, "r")
    expect(f.size).to eql 6221 
  end

  it 'should create one recognized xml document' do
    fn = @document.save_file_name(0)
    File.delete(fn) if(File.exists? fn)
    expect(@document.save_report(0)).to_not be nil
    expect(File.exists? fn).to be true
    f = open(fn, "r")
    expect(f.size).to eql 6797 
  end

  it "should process a buffer" do
    #d = @processor.process("#{@config.base_path}/test_data/test2.txt") 
    #f = File.open "/home/dhf/Development/Reader/DocManager/testfile.txt"
    f = File.open "#{@config.base_path}/test_data/test.txt"
    m = f.read
    f.close
    d = @processor.process_buffer(m)
    expect(d.reports.count).to eql 1
    #d = @processor.process("/home/dhf/Development/Reader/DocManager/testfile.txt") 

  end
end

describe "processing PDF" do
  puts "Process PDF Test"
  before :each do

    @env_name = "./spec/fixtures/processors/test_reader/"
  #  @config =IDSReader::Config.configure_environment(@env_name)
    @reader =IDSReader.new(@env_name)
    @config = $configuration
    @processor = @reader.processor

    #@processor = @config.create_processor

  #  @document = @processor.process("#{@config.base_path}/test_data/test.txt") 

    #@document = @processor.document_path("#{@config.base_path}/test_data/test.txt")
  end

  # it "should process a pdf output file" do
  #   #d = @processor.process("#{@config.base_path}/test_data/test2.txt")
  #   #f = File.open "/home/dhf/Development/Reader/DocManager/testfile.txt"
  #   f = File.open "#{@config.base_path}/test_data/consult.pdf"
  #   m = f.read
  #   f.close
  #   d = @processor.process_buffer(m)
  #   expect(d.reports.count).to eql 1
  #   puts "Data found: #{d.report(0).data}"
  #
  #   #d = @processor.process("/home/dhf/Development/Reader/DocManager/testfile.txt")
  #
  # end

  # it "should process a a pdf output file" do
  #   #d = @processor.process("#{@config.base_path}/test_data/test2.txt")
  #   f = File.open "/home/dhf/Development/Reader/DocManager/testfile.txt"
  #   #f = File.open "#{@config.base_path}/test_data/consult.pdf"
  #   m = f.read
  #   f.close
  #   d = @processor.process_buffer(m)
  #
  #   expect(d.reports.count).to eql 1
  #   puts "Data found: #{d.report(0).data}"
  #
  #   #d = @processor.process("/home/dhf/Development/Reader/DocManager/testfile.txt")
  #
  # end
=end

end  
#require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'pry'
require './spec/utilities/test_setup'
require './models/config.rb'



describe Report do
  before :each do

    @ts = TestSetup.new
    @ts.create_environment
    @ts.create_data_dictionary
    @ts.create_definitions

    @config = Config.new()

    @reader = Reader.new()
    @processor = @reader.processor
  end
	#
	# before :all do
  #   options = {}
  #   options[:reader] = 'reader'
  #   @config = Config.new(options)
  #   @reader = Reader.new(@config)
  #   @processor = @reader.processor
	# end

  describe "should extract and process each report " do
    before :each do

      @ts = TestSetup.new
      @ts.create_environment
 
      @ts.create_data_dictionary
      @ts.create_definitions

      @config = Config.new()

      @reader = Reader.new()
      @processor = @reader.processor
      @document = @processor.process ("./spec/fixtures/processors/test_reader/test/test_data/consult.pdf.txt")
    end
    # before :all do
    #   # @env_name = "./spec/fixtures/processors/test_reader/"
    #   #IDSReader::Config.configure_environment(@env_name)
    #   # @config =IDSReader::Config
    #   # @processor =IDSReader::Processor.new(@config)
    #
    #   #@env_name = "./spec/fixtures/processors/test_reader/"
    #   # @reader = Reader.new('reader')
    #   # @config = $configuration
    #   # @processor = $reader.processor
    #
    #   @document = @processor.process_file ("./spec/fixtures/processors/test_reader/test/test_data/consult.pdf.txt")
    #
    # end
      
    it "should count reports in document" do
      expect(@document.reports.length).to eql 1
      expect(@document.unknown_reports.length).to eql 0
    end
    
    it "should create an XML of the report" do
      expect(@document.report(0).to_xml).to match /<report>/
    end

    it 'should return the value of a field by name- 33', focus: true do
      rep = @document.report(0)
#binding.pry
      expect(rep.field(:mrn)).to eql "00714776"
      expect(rep.field(:pat_name)).to eql 'FRENCH, DONALD'
    end

    # it "should string of d-file data elements" do
    #   @processor.document_path = "./spec/fixtures/processors/test_reader/test/test_data/test1.txt"
    #   @document = @processor.document
    #   expect(@document.process_document).to eql 1
    #   expect(@document.reports[0].dfile_data.length).to eql 103
    # end
  end

  describe "Page management " do
    before :each do
      lines = [
        "telephone at ((513) 636-8313) to arrange",
        "another line of page 1",
        "\f"]
      @report = Report.new()
      @report.add_page(lines)
      lines = [
        "second page of report",
        "another line of page 2",
        "\f"]
        @report.add_page(lines)
    end
#
# #    it "should remove formfeed from last line" do
# #      @report.lines[@report.lines.length - 1].should == ""
# #    end

    it "should return the specified page" do
      expect(@report.page(0)).to eql  ["telephone at ((513) 636-8313) to arrange", "another line of page 1", "\f"]

      expect(@report.page(1)).to eql [
        "second page of report",
        "another line of page 2",
        "\f"]
    end
  end

  describe "report type detection helpers" do
    before :all do

      # @reader = Reader.new()
      # #@config = @reader.configuration
      # @processor = @reader.processor

      @document = Document.new(
        :lines => [
          "telephone at ((513) 636-8313) to arrange",
          "for return of this material to us.",
          "",
          "EMERGENCY DEPARTMENT VISIT -- Record Review",
          "April 10, 2002",
          "",
          "Primary Care Provider: CEPIN, DANIEL          Arrival Date: 04/10/2002 09:51",
          "Referral: REFDOC   more info",
          "Patient Name: PTNAME          Date of Birth: 03/30/1914    Age: 88          Sex: Female",
          "Med Rec #: 78559          Account #: 6572463          Acuity: 3 - Urgent",
          "Insurance: INSUR",
          "ED Physician: ERPHYS          ED Res | PNP: CONSLT",
          "Chief Complaint: burning in chest",
          "Discharge Diagnosis: DIAG",
          "Disposition: DISPO",
          "Prescriptions: RX",
          "Discharge Instructions: DXINS",
          "Discharge Note: FREE_TEXT",
          "Discharge Date: ",
          "\f"]
  # End of file indicates end of a page also end of report.
  # End of a page is also indicated by a formfeed.
        )
        @document.extract_reports
    end

    it "should find using a regex" do
      expect(@document.raw_reports.length).to eql 1
      expect(@document.raw_reports[0].first_identifier?(/EMERGENCY DEPARTMENT VISIT/, :line => 4)).to be_truthy
      expect(@document.raw_reports[0].first_identifier?(/.+\s+\d{,2},\s\d{4}/, :line => 5)).to be_truthy
    end

    {
      'EMERGENCY DEPARTMENT VISIT|4' => 1,
      'EMERGENCY DEPARTMENT VISIT|3' => 2,
      'Referral: REFDOC|8' => 1,
      'hello abc|3' => false
    }.each do |prompt, index|
      values = prompt.split('|')
        it "first_identifier?('#{values[0]}', :line => #{values[1]}).should == #{index}" do
          expect(@document.raw_reports.length).to eql 1
          expect(@document.raw_reports[0].first_identifier?(values[0], :line => values[1])).to eql index
        end
      end

    it "should find 1 report" do
	    expect(@document.raw_reports.length).to eql 1
    end

    it "should not set the first line of recognized document before the true first line" do
      expect(@document.raw_reports[0].first_identifier?('EMERGENCY DEPARTMENT VISIT', :line => 7)).to be_falsey
    end

    it "should use firs and other identifiers setting the first line base upon the line of the first_identifier" do
      expect(@document.raw_reports[0].first_identifier?('EMERGENCY DEPARTMENT VISIT', :line => 1)).to be_truthy
      expect(@document.raw_reports[0].other_identifier?("Primary Care Provider", :line => 4, :column => 1)).to be true
   #   expect(@document.raw_reports[0].other_identifier?("Primary Care Provider", :line => 1..5, :column => 1)).to be true
      expect(@document.raw_reports[0].other_identifier?("Primary Care Provider", :line => [2,4,6], :column => 1)).to be true
      expect(@document.raw_reports[0].other_identifier?("Primary Care Provider", :line => [2,7,6], :column => 1)).to be false
      expect(@document.raw_reports[0].other_identifier?("Primary Care Provider", :line => 'a')).to be false
    end

    it "should allow for other_identifiers to be located prior to the first one" do
      expect(@document.raw_reports[0].first_identifier?('Primary Care Provider',:line => 7)).to be_truthy
      expect(@document.raw_reports[0].other_identifier?("EMERGENCY DEPARTMENT VISIT", :line => 4, :column => 1)).to be_truthy
    end

    it "should not find an other_identifier on invalid line" do
      expect(@document.raw_reports[0].first_identifier?('EMERGENCY DEPARTMENT VISIT', :line => 4)).to be_truthy
      expect(@document.raw_reports[0].other_identifier?("Primary Care Provider",  :line => 5, :column => 1)).to be false   #this is not the report so should fail
    end
  end

end
#0123456789012345678901234567890
#today is 07/22/2010 Thursday

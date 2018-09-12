#require File.dirname(__FILE__) + '/../../spec_helper.rb'
require './spec/utilities/test_setup'
require './models/config.rb'

describe Descriptor do

  before :each do

    @ts = TestSetup.new
    @ts.create_environment
    @ts.create_data_dictionary
    @ts.create_definitions

    @config = Config.new()
    @reader = Reader.new()

    @processor = @reader.processor

    @d = Descriptor.new(
	   Document.new(
        #                    1         2         3         4         5         6
        #           123456789012345678901234567890123456789012345678901234567890
  :lines => ["abc xyz 123        rst  ",
                   "Second line of report",
                   "Patient:   Test Patient              Date of Birth: 12/15/1950",
                   "Account#: 12345  M.R.#: M12345 ____________ John A. Smith, M.D. 02/15/2010",
                   "cc:",
                   "Theresa French MD DIAGNOSTIC REPORT",
                   "Last Page of Report"   ]   
      )
    )  
  end


  it "prompt with strings should work correctly" do
    expect(@d.prompt("xyz")).to eql [1, 9]
    expect(@d.prompt("xyz", :start_of_prompt => true)).to eql [1, 5]
  end
  
  it "should find prompt and skip following blanks " do
    expect(@d.prompt("xyz", :skip_blanks => "All")).to eql [1, 9]
    expect(@d.prompt("wxyz", :skip_blanks => true)).to eql [nil, nil]
    expect(@d.prompt("123", :skip_blanks => true)).to eql [1, 20]
    expect(@d.prompt("123", :skip_blanks => 4)).to eql [1, 16]
    expect(@d.prompt("123", :skip_blanks => 30)).to eql [1, 20]   #limit to actual spaces.
  end
  
  it "should not find invalid prompt" do
    expect(@d.prompt("wxyz")).to eql [nil, nil]
  end
  
  it "should find prompts with start_line" do
    expect(@d.prompt("xyz", :start_line => 2)).to eql [nil, nil] #value before start line
    expect(@d.prompt("xyz", :start_line => 10)).to eql [nil, nil] # invalid start line
    expect(@d.prompt("xyz", :start_line => 1)).to eql [1, 9] #valid start line
  end
  
  it "should find prompt after start_column" do
    expect(@d.prompt("xyz", :start_column => 10)).to eql [nil, nil]
    expect(@d.prompt("xyz", :start_column => 3)).to eql [1, 9]
  end
  
  it "should find prompt before end_column" do
    expect(@d.prompt("xyz", :skip_blanks => "no", :end_column => 3)).to eql [nil, nil]
    expect(@d.prompt("xyz", :skip_blanks => "no", :end_column => 10)).to eql [1, 8]
  end
  
  it "should find prompts before an end_line value" do
    expect(@d.prompt("xyz", :skip_blanks => "no", :end_line => 1)).to eql [1, 8]
    expect(@d.prompt("xyz", :skip_blanks => "no", :end_line => 10)).to eql [1, 8] #default to end of lines
    expect(@d.prompt("line", :end_line => 1)).to eql [nil, nil] # value after end
  end
  
  it "should find a prompt at a particular column" do
    expect(@d.prompt("xyz", :column => 8)).to eql [nil, nil]
    expect(@d.prompt("xyz", :column => 5, :start_of_prompt => true)).to eql [1,5]
  end
  
  it "should find prompt at a particular line" do
    expect(@d.prompt("xyz", :skip_blanks => "no", :line => 1)).to eql [1, 8]
  end
  
  it "should not find a string prompt trying to use regex" do
    expect(@d.prompt("M.R.#:[ ]*")).to eql [nil, nil]
  end      
  
  it "should fine a prompt that has regex as part of the prompt" do
    expect(@d.prompt("M.R.#:")).to eql [4, 25]
  end
  
  it "should find a prompt using a regex" do
    expect(@d.prompt(/M.R.#:[ ]*/)).to eql [4, 25]
  end
  
  it "should not skip blanks when using a regex" do
    expect(@d.prompt(/M.R.#:/)).to eql [4, 24]
  end
  
  it "should skip all blanks" do
    expect(@d.prompt("123", :skip_blanks => 'No')).to eql [1,12]
    expect(@d.skip_blanks).to eql [1,20]
  end
  
  it "should limit number of blanks skipped to nonblank" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip_blanks(2)).to eql [1,14]
  end

  it "should limit number of blanks skipped to specified" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip_blanks(2)).to eql [1,14]
  end
   
  it "should skip valid columns" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip(:column => 1)).to eql  [1, 1]
    expect(@d.skip(:column => 24)).to eql [1, 24]
  end
 
  it "should skip to valid row" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip(:row=>2)).to eql [2,12]
    expect(@d.skip(:row=>2, :column=>1)).to eql [2,1]
    expect(@d.skip(:column => 10)).to eql [2, 10]
  end

  
  it "should not skip to valid row" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip(:row=>8)).to eql [nil, nil]
    expect(@d.skip(:row=>0)).to eql [nil, nil]
  end
   
  it "should not skip to invalid column " do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip(:blank=>true, :column=>23)).to be_nil
    expect(@d.skip(:column=>2)).to eql [1,2]  #be_nil
    expect(@d.skip(:column=>0)).to be_nil
  end 
  
  it "should do nothing if number specified without blank" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.skip(:number => 2)).to eql [1,12]
  end

  it "should extract data using regex" do
	  x = @d.field('Account#:', 'acct_num', :regex => /\d+/ )
	# 
    expect(@d.extract_regex(:mrn, /\s*(\d+)/, :row=>1, :column=>9)).to eql "123"
    # expect(@d.extract_regex(:mrn, /\s*(\d+)/, :row=>1, :column=>7)).to eql "123"
    # expect(@d.extract_regex(:mrn, /\s*(\d+)/, :row=>1, :column=>1)).to eql "123"
  end
  

  it "should stop extraction using an ends_with option default lower case" do
    expect(@d.prompt("M.R.#:")).to eql [4, 25]
    expect(@d.extract_text(:mrn, :ends_with => "___")).to eql 'm12345'
  end

  it "should extract if ends_with string not found" do
    expect(@d.prompt("cc:")). to eql [5, 4]
   expect(@d.extract_text(:pcp, :add_rows => 1, column: 1, ends_with: 'DIAG')).to eql'theresa french md'
  end

  it "should not extract if is not value" do
    expect(@d.prompt("M.R.#:")).to eql [4, 25]
    expect(@d.extract_text(:mrn,  :not => 'm12345')).to be_nil

  end
  
  it "should extract a text field using ends_with as a regex" do
    expect(@d.prompt(/___+/)).to eql [4, 44]
    expect(@d.extract_text(:mrn, :ends_with => /\d{2}\/\d{2}/)).to eql "john a. smith, m.d."
  end

  it "should store extracted data" do
    expect(@d.extract_regex(:mrn, /(\d+)/, :row=>1, :column=>1)).to eql "123"
    expect(@d.data[:mrn]).to eql '123'
  end    
     
  it "should extract text" do
    expect(@d.prompt("123")).to eql [1,20]
    expect(@d.extract_text(:mrn)).to eql "rst"
  end

  it "should not process missing data_name" do
    expect(@d.prompt("123")).to eql [1,20]
#    @d.skip_blanks
    expect(@d.extract_text(:junk)).to be_nil
  end
  
  it "should handle triming properly on text" do
    expect(@d.prompt("123", :skip_blanks => "no")).to eql [1,12]
    expect(@d.extract_text(:pcp, :downcase => true, :skip_blanks => "no", :nostrip=>true)).to eql "        rst  "
    expect(@d.extract_text(:pcp, upcase: true)).to eql 'RST'
  end 
  
  it "should find and extract a basic text field" do
    expect(@d.field("123", :pcp, :skip_blanks => "no")).to eql 'rst'
    expect(@d.field("123", :pcp, :skip_blanks => "no", :nostrip=>true)).to eql "        rst  "
    expect(@d.field("123", :pcp, upcase: true, :nostrip=>true)).to eql "RST  "
    expect(@d.field("123", :pcp, upcase: true)).to eql "RST"
  end

  it "should find and extract with increment to row and/or column" do
    expect(@d.field("xyz", :pcp, :add_columns => 4)).to eql "rst"
    expect(@d.field("xyz", :pcp, :nocase => true, :add_columns => -1, :add_rows => 1)).to eql "line of report"
  end

  it "should extract a field with a regex prompt" do
    expect(@d.field(/___+/, :pcp, :ends_with =>/\d{2}\/\d{2}/)).to eql "john a. smith, m.d."
  end

  it "should fing and extract a basic regex field" do
    expect(@d.field("xyz", :pcp, :regex =>  /\s*(\d+)/)).to eql "123"
  end
  
  it "should find and extract a patient name" do
    expect(@d.field("Patient:", :pat_name, :nocase => true, :ends_with => "Date of")).to eql "test patient"
    expect(@d.field("Patient:", :pat_name, :ends_with => "Date of", :downcase=> true)).to eql "Test Patient"
  end
  
  it "should find and extract a birthdate" do
    expect(@d.field("Date of Birth:", :dob)).to eql "12/15/1950"
  end

  it "Should provide DataElement access using symbols" do
    expect(@d.data_element(:pat_name).name).to eql 'pat_name'
  end
  
  it "Should provide a nil for an unknown DataElement" do
    expect(@d.data_element(:junk)).to be_nil
  end
  
  it "Should provide DataElement access using a string" do
    expect(@d.data_element(:pat_name).name).to eql 'pat_name'
  end


end

#
#describe "should extract and process each report " do
#  it "should count reports in document" do
#    @processor = Processor.new
#    @processor.descriptors
#    @document = Document.new(:document_file => "#{DEFAULT_DOCUMENTS_PATH}/test.txt")
#  
#    @document.process_reports.should == 1     #only one valid report found 
##     @document.reports.each do |r| 
##       if r.report_type.nil?
##         puts "Unknown Report" 
##       else 
##         puts "Report Type #{r.report_type.title}"
##       end
##     end
#  end
#end
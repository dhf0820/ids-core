#require File.dirname(__FILE__) + '/../../spec_helper.rb'
#
describe 'Document Line' do
  it "should determine if a line contains a form feed" do
    ffs = "string containing formfeed\f\n"
    nff = "string with no formfeed\n"
    expect(ffs.contains_form_feed?).to be_truthy
    expect(nff.contains_form_feed?).to be false 
  end
  
  {
    'End of Report' => true,
    '  end  of   report  ' => true,
    'tEnd of report' => false,
    'page 1 of 0' => true,
    ' page  20  of 20' => true,    
    'end of reporting' => false,
    'Continued next page' => false  # check f this is true or false
#    "formfeed\f" => true
  }.each do |line, result|
    it "'#{line}'.end_of_report? => #{result}" do
      expect(line.end_of_report?).to eql result
    end
  end
  
  {
    'nopage 1' => false,
    'page   1' => true,
    'page 1 of 0' => true,
    'page 100' => false
  }.each do |line, result|
    it "'#{line}'.first_page_of_report?.should == '#{result}'" do
      expect(line.first_page_of_report?).to eql result
    end
  end  
end
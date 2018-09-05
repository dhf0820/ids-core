#require File.dirname(__FILE__) + '/../../spec_helper.rb'



describe Page do

  before :all do
    @lines = [
      "Line 1",
      "Line 2",
      "\f",
      "Line 3",
      "Line 4\f",
      "Line 5"
      ]
    @page = Page.new(0, 2, @lines[0...3])
  end
  
  it "should create a new page" do
    expect(@page.first_line).to eql 0
    expect(@page.last_line).to eql 2
    expect(@page.line(0)).to eql "Line 1"
  end
  
  it "should return without a formfeed is default" do
    expect(@page.lines).to eql ["Line 1", "Line 2","\f"]
  end
  
 # it "should return with the formfeed if requested" do
 #   page =IDSReader::Page.new(0, 2, @lines[0...2])
 #   page.lines(true).should == ["Line 1", "Line 2","\f"]
 # end
  
  it "should return one string with all the lines in it" do
    expect(@page.to_str).to eql "Line 1\nLine 2\n\f"
  end
  
  it "should return an xml representation for a page" do
    expect(@page.to_xml).to eql "<page>Line 1\nLine 2\n\f</page>"
  end

end

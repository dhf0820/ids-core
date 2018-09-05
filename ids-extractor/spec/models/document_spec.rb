#require File.dirname(__FILE__) + '/../../spec_helper.rb'
require './spec/utilities/test_setup'
require './models/config.rb'

describe Document do

  before :each do

    @ts = TestSetup.new
    @ts.create_environment
    @ts.create_data_dictionary
    @ts.create_definitions

    @config = Config.new()

    @reader = Reader.new()
    @processor = @reader.processor
  end

  it "should count the number of pages in a two page document" do
    document = Document.new(
      :lines => [
        "Page 1",
        "Report 1 content",
        "last line of first page\fFirst line of page 2",
        "Second line of Page 2",
        "End of Report",
        "Last line of second page\f\f\f"
      ]
    )
    expect(document.collect_pages.length).to eql 2
    expect(document.pages.length).to eql 2
   end

  it "should count the number of pages in a one page document" do
      document = Document.new(
        :lines => [
          "Page 1",
          "Report 1 content",
          "last line of first page\f\f\f\f"
        ]
      )
      expect(document.collect_pages.length).to eql 1
      expect(document.pages.length).to eql 1
  end


  it "three pages in document non-terminated last page" do
    document = Document.new(
      :lines => [
        "Page 1",
        "Report 1",
        " content",
        "\f",
        "Page 2",
        "Content for page 2",
        FORM_FEED_CHAR,
        "Page 3",
        "Content of page 3",
        "End of Report",
        "Non ff terminated page page"
      ]
    )
    expect(document.collect_pages.length).to eql 3
    expect(document.pages.length).to eql 3
  end

  it "should throw ArgumentError if neither file or lines is provided" do
    expect(lambda{document =  Document.new()}).to raise_error(ArgumentError)
  end

  describe "detecting the end of a report and split them into smaller files" do

    it "three pages in document non-terminated last page" do
      document = Document.new(
        :lines => [
          "Page 1",
          "Report 1",
          " First Page of 3 page document",
          "\f",
          "Page 2",
          "Content for page 2 or 3 page document\fPage 3",
          "Content of page 3 of 3 page document",
          "End of Report",
          "Non ff terminated page page"
        ]
      )
      expect(document.extract_reports.length).to eql 1
      #document.reports.each {|report| report.show_lines }
    end

    it "one reports per document" do
      document = Document.new(
        :lines => [
          "Page 1",
          "Report 1 content \f",
          "Page 2",
          "End of Report",
          FORM_FEED_CHAR
        ]
      )
      expect(document.extract_reports.length).to eql 1
      expect(document.raw_reports.length).to eql 1
    end

    it "should give one report with the reports method" do
      document = Document.new(
        :lines => [
          "Page 1",
          "Report 1 content \f",
          "Page 2",
          "End of Report",
          FORM_FEED_CHAR
        ]
      )
      expect(document.extract_reports.length).to eql 1
      expect(document.raw_reports.length).to eql 1
    end

   it "should return an empty set of reports before any processing" do
     document = Document.new(
       :lines => [
         "Page 1",
         "Report 1 content \f",
         "Page 2",
         "End of Report",
         FORM_FEED_CHAR
       ]
     )

     expect(document.reports.length).to eql 0
   end

   it "should return nil if trying to recognize more reports than found" do
     document = Document.new(
       :lines => [
         "Page 1",
         "Report 1 content \f",
         "Page 2",
         "End of Report",
         FORM_FEED_CHAR
       ]
     )
     expect(document.extract_reports.length).to eql 1
     expect(document.determine_report_type(1)).to be_nil
   end

   it "one two-page-report per document" do
     document = Document.new(
       :lines => [
         'Page 1 of Report 1',
         'Page 1 of 1',
         'Last line of report 1',
         FORM_FEED_CHAR,
         'First Page of Report 2',
         'Page 1 of 1' # End of file terminates a report
       ]
     )
     expect(document.extract_reports.length).to eql 2
   end

    it "two one-page-reports per document" do
      document = Document.new(
        :lines => [
          'Page 1 of Report 1',
          'Page 1 of 1',
          'Last line of report 1',
          FORM_FEED_CHAR,
          'First Page of Report 2',
          'Page 1 of 1' # End of file terminates a report
        ]
      )
      expect(document.collect_pages.length).to eql 2        # number of pages in document
      expect(document.extract_reports.length).to eql 2
      expect(document.extract_reports.first.lines).to eql [
        'Page 1 of Report 1',
        'Page 1 of 1',
        'Last line of report 1',
        "\f"]
    end
  end

  it "should detect three reports in a document" do
    document = Document.new(
      :lines => [
        'This is page 1 report 1',
        'Page 1 of 2',
        FORM_FEED_CHAR,
        'This is page 2 of Report 1',
        'La la la',
        'Page 2 of 2',
        FORM_FEED_CHAR,
        'page 1',
        'This is page 1 of Report 2',
        'ha ha ha',
        '  End of report  ',
        FORM_FEED_CHAR,
        'This is page 1 of Report 3',
        ' ten ten ten',
        FORM_FEED_CHAR
      ]
    )
    expect(document.extract_reports.length).to eql 3
    expect(document.raw_report(0).page(0)).to eql [
      'This is page 1 report 1',
      'Page 1 of 2',
      "\f"
    ]
  end

  it "should detect three reports in a document" do
    document = Document.new(
      :lines => [
        'This is page 1 report 1',
        'Page 1 of 2',
        FORM_FEED_CHAR,
        'This is page 2 of Report 1',
        'La la la',
        'Page 2 of 2',
        FORM_FEED_CHAR,
        'page 1',
        'This is page 1 of Report 2',
        'ha ha ha',
        '  End of report  ',
        FORM_FEED_CHAR,
        'This is page 1 of Report 3',
        ' ten ten ten',
        FORM_FEED_CHAR
      ]
    )
#    document.reports.each {|report| report.show_lines }
    expect(document.extract_reports.length).to eql 3
    expect(document.extract_reports[0].lines).to eql [
      'This is page 1 report 1',
      'Page 1 of 2',
      "\f",
      'This is page 2 of Report 1',
      'La la la',
      'Page 2 of 2',
      "\f"
    ]

    expect(document.extract_reports[1].lines).to eql [
      'page 1',
      'This is page 1 of Report 2',
      'ha ha ha',
      '  End of report  ',
      "\f"
    ]

    expect(document.extract_reports[2].lines).to eql [
      'This is page 1 of Report 3',
      ' ten ten ten',
      "\f"
    ]
   end
end



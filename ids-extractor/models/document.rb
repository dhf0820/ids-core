# A document can store one or more reports
# There is a concept of a current report which contains one or more pages.
# A document should provide methods to help a descriptor analyze itself
#
require_relative '../lib/ids-reader'
#module IDSReader
  class Document
    
    attr_reader :document_file, :document_name, :report_dir
    attr_accessor :current_page, :current_line, :current_first_line
    
    def initialize(options ={})
      @config = Config.active
      #@config = config
#      mode = @config.runtime_mode

     # @log = Logging::Logger[ "Document"] ##{@config.processor}::document"]


      #log = Logger.new(@config.log_file, shift_age = 7, shift_size = 1048576)
      @document_file = options[:file_to_process] || nil
      #puts "   PROCESSING file #{@document_file}"
      @document_name = File.basename(@document_file) unless @document_file.nil?
      @lines = options[:lines] || nil # holds all lines of a document
      @buffer = options[:buffer] || nil # holds characters read from file or provided
      raise ArgumentError.new('no file to process or array of lines given.') if @document_file.nil? && @lines.nil?
      @pages = []  
      @valid_reports = []   # only the reports from this raw document
      @raw_reports = []
      @unknown_reports = [] #the actual pages or portions of pages undefined
    end
        
  
    def split_document
#      @log.debug5("Processing Document: #{@document_file}")
      @raw_reports = []
      @valid_reports = []
      @unknown_reports = []
      @pages = []
      extract_reports
      valid_reports = extract_data_from_reports
      reports.each do |report|
        unless report.report_type.nil?
          report.assign_class
          report.cleanup
          report.post_process
        end
      end
      valid_reports
    end

    def process_document
     # puts "ProcessDocument #{@document_file}"
#      @log.debug5("Processing Document: #{@document_file}")
      #puts "\n     Document.ProcessDocument"
      @raw_reports = []
      @valid_reports = []
      @unknown_reports = []
      @pages = []
      extract_reports

      valid_reports = extract_data_from_reports
      #puts "  ValidReports: #{valid_reports.count} -- #{valid_reports}"

      # puts "\n     Number of reports found: #{reports.count}"
      reports.each do |report|
        unless report.report_type.nil?
          #STDERR.puts(" Document.ProcessDocument Report #{report.data}")
          report.assign_class
          report.cleanup
          report.post_process
        end
      end

      docs = valid_reports
	    #puts "    ProcessDocument returning #{docs}"

			docs
    end

    def save_report(report_num, mode = :xml)
      raise ArgumentError.new('No report matches number #{report_num}') if (@valid_reports.count < report_num)
      base_fname = document_name.split('.')[0]
      begin
        r = report(report_num)
        save_to = save_file_name(report_num, mode)
        file = open(save_to, "w")
        result = r.save(file, mode)
        file.close
        file = nil
        return save_to
      # rescue => e
      #   binding.pry
      #   file.close unless file.nil?
      #   return nil
      end
    end

    def save_unknown_report(num)
      Raise ArgumentError.new("Requested unknown report number is invalid")  if @unknown_reports.count < num
      raw = @unknown_reports[num]
      begin
        save_to = unknown_file_name(num)
        file = open(save_to, "w")
        raw.pages.each do |page|
          lines = page.lines
          lines.each do |l|
            file.puts l
          end
          file.write "\f"
        end
        file.close
        file = nil
        return save_to
      rescue => e

        file.close unless file.nil?
        return nil
      end
    end

    def save_file_name(id, mode = :xml)
      base_fname = document_name.split('.')[0]
      out_path = @config.output_path + base_fname + ".#{id}"
      out_path = out_path + ".xml" if(mode == :xml)
      #puts "GoodFile = #{out_path}"
      out_path
    end

    def unknown_file_name(id)
      base_fname = document_name.split('.')[0]
      out_path = @config.output_path + base_fname + ".#{id}.unk"
      #puts "UnknownFile = #{out_path}"
      out_path
    end

    def reports
      @valid_reports
      # if id < @valid_reports.count
      #   @valid_reports[id]
      # else
      #   raise ArgumentError.new('Report is invalid')
      # end
    end
    
    def report(report_number)
      if report_number <  @valid_reports.count  
        @valid_reports[report_number]
      else
        raise ArgumentError.new("Report number is invalid")
      end

      @valid_reports[report_number]
    end
       
# Extract all reports from the document file. 
 
    def extract_reports
      #puts "  Document.extract_reports"
      # consider changing this to use split on a raw array to split by \f then by \n
      @raw_reports = []
      pending_report = true
      lines # read all the lines in the document file
      
      @pages = []
      collect_pages
      #puts "  collect_pages returned #{@pages}"
      # We now have all the lines of the file and an array of the sets of pages in the file
      # Now determine where a report ends and collect those pages.
      r = Report.new()
      @pages.each_with_index do |page, i|
        r.add_page(@lines[page.first_line..page.last_line])
        pending_report = true
        current_line = page.first_line
        while current_line <= page.last_line
          if @lines[current_line].end_of_report?
            @raw_reports << r
            r = Report.new()
            pending_report = false
            break #report was added to array of reports 
          end 
          current_line += 1  
        end
  
      end
      if pending_report
        @raw_reports << r
      end 
      @raw_reports
    end
   
#Collect the pages of the current report into an array of Page objects
#Look for page terminator, currently only formfeed, but later could include length of page
    def collect_pages
      #find page terminator
      start_line = 0
      current_line = 0
      @lines.each_with_index do |line, i|
        current_line = i
        if end_of_page?(line, i)
          @pages << Page.new(start_line, i) # every page in raw document
          start_line = i + 1               
        end 
      end #end of line.each
      
      if current_line > start_line
        page = Page.new(start_line, current_line)
        @pages << page
      end
      #puts "   collect_pages found #{@pages.length} pages"
      @pages 
    end
    
    def end_of_page?(line, i)
      return false unless line.contains_form_feed?
      split = line.split("\f") # split contains both parts of the line
      if split.length == 0
        @lines[i] =  "\f"
      else
        @lines[i] = split[0] + "\f"
        #if line is several formfeeds then only one is inserted the rest are skipped
        insert_point = i + 1
        split[1..-1].each_with_index do |sline, j|
          if sline.length > 0
            @lines.insert(insert_point, sline)
            insert_point += 1
          end
        end  
      end         
      return true
    end
  
 
    def extract_data_from_reports
      valid_reports = 0
      raw_reports.each_with_index do |r, i|
			#puts "   extract_data_fron_report working of type = #{r.report_type}"
        #@log.debug8 "extract_data_fron_report working on type = #{r.report_type}"
        rt = determine_report_type(i)
        if r.report_type.nil?
          handle_unknown_report(i)
        else
          reports << r
					#puts "   #{r.report_type.class.title} found with #{r.pages.length} pages"
          #@log.info "#{r.report_type.class.title} found with #{r.pages.length} pages"
          valid_reports += 1
        end
      end
      valid_reports
    end

    def reports_count
      return reports.count
    end

    def determine_report_type(report_number)
      return nil unless report_number < raw_reports.length
      r = raw_reports[report_number]
      r.report_type = nil
      keys = Config.descriptor_keys

      keys.each do |key|
      #  binding.pry
        recognizer_class = Config.recognizer(key).recognizer

      # end
      # recognizers.each do |recognizer_class|
      #
        if recognizer_class.recognize?(r) #found a valid report

          r.report_type = recognizer_class.new()
          r.report_type.document = self
          r.report_type.add_data_elements
      #    binding.pry
          begin
            r.extract_data
          rescue NoMethodError => e
            #@log.error "Extract NoMethod error #{e}"
            raise ReportReader::ExtractError.new(e)
#            raise ReportReader::ExtractError.new(e.msg)
          end

          #puts "Is #{descriptor_class.title}"
          break
        end
        #puts "Not #{descriptor_class.title}"
      end
      #puts "Returning #{r.report_type.class.name}"
      r.report_type
    end
    
    def pages
      @pages
    end
  
    def lines
      @lines ||= read_lines
    end
  
    # find the end of the current page from the starting location
    def find_page_end
      
    end
  
    def to_s
      @document_file
    end

    def raw_reports
      @raw_reports
    end

    def unknown_reports
      @unknown_reports
    end
    
    def raw_report(report_number)
      return nil if @raw_reports.length < report_number
      @raw_reports[report_number]
    end

    def unknown_report(report_number)
      return nil if @unknown_reports.length < report_number
      @unknown_reports[report_number]
    end

  
  protected

    def handle_unknown_report(report_number)
#puts "unknown report"
      puts "Report #{report_number} is unknown in file #{@document_file}"
      @unknown_reports << raw_reports[report_number]
    end
  # Read all lines from a document file. Possibly limit to some reasonable number. TBD  
  
    def read_lines
      File.read(@document_file).split("\n")
    end
  
  #    def write_lines(lines)
  #      File.open(document_file, 'w') do |f|
  #        lines.each { |line| f.puts(line) }
  #      end
  #    end  
  end
#end
require 'builder'

#module IDSReader
  class Report
  
    attr_accessor :report_type    # class of report found
    
    def initialize
      @config = $config
      @pages = []   
      @lines = []  #lines in this report
      @report_type = nil

      #@log = Logging::Logger["#{$reader.processor}::document::report"]
    end
  
    def cleanup
      @report_type.cleanup(@pages)
    end
    
    def post_process
      @report_type.post_process(@pages)
    end
    
    def assign_class
      @report_type.assign_class
    end
    
    def add_page(lines)
      return @pages if lines.nil? or lines.length == 0
      first_line = @lines.length
#      lines[lines.length - 1].sub!("\f", "") 
      @lines.concat(lines)
      last_line = @lines.length - 1  
      @pages << Page.new(first_line, last_line, lines)
    end
  
    def show_lines
      @pages.each_with_index do |page, i|
        puts "Page #{i + 1}:"
        page.lines.each do |line|
          puts "   #{line}"
        end
      end
    end
    
    def lines
      @lines
    end
    
    def data
      @report_type.data unless @report_type.nil?
    end
    
    def pages
      @pages
    end
    
    def fields
      @report_type.data
    end

    def field(name)
      name = name.to_s if (name.class.name == 'Symbol')
      data[name] unless data.nil?
    end
    
    def []=(k,v)
      if k.class.name == 'String'
        k = k.to_sym
      end
      return nil unless DataElements[k].has_key?(k)
      @report_type.data[k]= v
    end
      
    def page(page_number)
      return nil if pages.length < page_number
      pages[page_number].lines
    end
    
    def first_line_index
      @first_line_index + 1  
    end
    
    def extract_data
     # binding.pry
      @report_type.data
    end
  
  # this needs to be in document
    def save(file, mode = :xml)

      case mode
        when :dfile
          to_dfile(file)
        when :xml
          to_xml(file)
      end
    end
  
    def to_xml(file = nil)
      if file.nil?
        buffer = ""
        x = Builder::XmlMarkup.new(:target => buffer, :indent=> 4)
      else
        x = Builder::XmlMarkup.new(:target => file, :indent=> 4)
      end
      x.instruct!
      x.fields do
        @report_type.data.each do |field, value|
          unless value.blank?
            x.field do
              x.name(field)
              x.value(value)
            end
          end
        end
      end
      doc = ""
      @pages.each do |page|
        doc << page.to_str
           #x.page page.to_str
      end
      x.report doc
      # x.report do 
      #   doc = ""
      #   @pages.each do |page|
      #     doc << page.to_str
      #      #x.page page.to_str
      #   end

      # end

      buffer 
    end

    def to_json
      hash = HashWithIndifferentAccess.new 
      field_hash = HashWithIndifferentAccess.new 
      data.each do |field, value|
        unless value.blank?
          field_hash[field] = value
        end
      end

      doc = ""
 #     @pages.each do |page|
 #       doc << page.to_str
 #     end
      hash[:fields] = field_hash
 #     hash[:report] = doc
      hash.to_json

    end


    def dfile_data
      #binding.pry
      dfile = StringIO.new 
      dfile.puts "---"
      fields.each do |field, value| 
        dfile.puts "#{field}: #{value}" unless value.nil? or value.empty?
      end
      dfile.puts "processor: #{Config.processor_name}"
      dfile.puts "{EndYaml}"  
      dfile.string
    end
          
    def to_dfile(file = nil)
      dfile = StringIO.new if dfile.nil?  
      dfile.puts dfile_data
      @pages.each do |page|
        dfile.puts page.to_str
      end
      file.puts dfile.string unless file.nil?
      dfile.string
    end
      
    
    # Find the identifier specified in the file. if found the @first_prompt_index is set relative to the specified line
    # For example, if the identifier is found on line 10 of the report but the :line values in the call is set to 4, the 
    # start of the document is actually on line 7 since that would put the found identifier on the proper line 4. The next_identifier?
    # calls are all in relation to this new start of document (line 7)
    # returns the start line of the report 1 based or false if not found
    
#TODO:  Could make the identifier search case insensitive
    def first_identifier?(identifier, options = {})
      #puts "First identifier: #{identifier} - options: #{options}"
      # TODO Need to log a descriptor error
      return false if options[:line].nil?
      identifier_line = options[:line].to_i - 1 # unless options[:line].nil? #line is passed as 1 based

#      @lines.each_with_index do |line, first_prompt_index|    
      identifier = Regexp.new(Regexp.escape(identifier)) if identifier.class == String
      # Look on each page for the prompt
      @pages.each_with_index do |page, page_number|
        page.lines.each_with_index do |line, first_identifier_index|
          #puts "looking for first #{identifier} in line #{first_identifier_index} = [#{line}]"
          if m = line.match(identifier)
           # puts "found it on #{first_identifier_index} prompt_line = #{identifier_line}"
            return false if first_identifier_index < identifier_line #found prompt earlier than expected. Possible just continue
          
            @first_line_index = first_identifier_index - identifier_line
            return @first_line_index + 1
          end
        end
      end
      return false
    end
  
    # Find the next identifier to identify the document. it must be on the specified line based upon the @first_line_index. 
    # If the :line parameter is set to line 6, then the prompt must be found on that line only returning true if found. 
    # We do not look on other lines   
    #
    #TODO: allow for specifying a range of lines on which the other identifier could be found
    #TODO: allow for an array of lines on which the identifier could be found
    
    def other_identifier?(identifier, options ={})

      which_lines = options[:line]  # on unique line, array or range of possible lines all 1 based
      #puts "    looking for other #{identifier} - options: #{options}   class_name: #{which_lines.class.name}\n"
      identifier = Regexp.new(Regexp.escape(identifier)) if identifier.class == String        
      page = @pages[0]
      case which_lines.class.name
        when 'NilClass'
          return false
        when 'Integer'
          # handle the case where the identifier can be only on one line
          #puts "first_index: #{@first_line_index}  which_lines: #{which_lines}"
          line = page.line(@first_line_index + which_lines - 1) # always in refernece to the logical first line of report
          #puts "  #{identifier} - #{line}"
          return true if identifier_on_line(identifier, line, options[:column])
        when "Array", "Range"
          if which_lines[0] == 'page'  #anywhere on the current page
            which_lines = (1..page.lines.count)
          end
          which_lines.each do |line_num|
            line = page.line(@first_line_index + line_num - 1)
            v = identifier_on_line(identifier, line, options[:column])
      #      puts "Line #{line_num} looking  in [#{line}]"

            return true if v == true
          end
        else
          puts "Invalid :line option #{which_lines.class} for #{identifier}"
          #@log.warn "Invalid :line option #{which_lines.class} for #{identifier}"
      end
      return false  # not found if it gets here
    end
    
  private
    def identifier_on_line(identifier, line, column = nil)
      #puts "id_on_line: #{identifier} - #{line} - #{column}"
      return false if line.nil? || line.length == 0 
      identifier = Regexp.new(Regexp.escape(identifier))  if identifier.class == String
      m = line.match(identifier)
      if m.nil?
        return nil # if m.nil?
      end

      return true if column.nil?
      return m.begin(0) == column - 1   
    end
  end
#end

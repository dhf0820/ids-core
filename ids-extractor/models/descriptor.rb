# = Descriptors
# Each report that can be identified in a raw file is identified by a descriptor file. This descriptor file extends Descriptor and contains
# the required self.recognize? and the extract methods.
#
# All line references in the descriptor are 1 based.
#module IDSReader
  class Descriptor  
    def initialize(document = nil)
      @config = $configuration
      @document = document
      @current_row = nil
      @current_column = nil
      @data = {}
    end
    
    def document(value)
      @document = value   
    end
    
    def document=(value)
      @document = value
    end
    
#over ride if necessary
    def status
      :process      #default
    end
    
#over ride if necessary
    def add_data_elements
  
    end
    
#over ride if necessary
    def post_process(pages)
    end

    def post_field(data_name)

    end
# Override if necessary to clean up anything about a report
    def cleanup(pages)
    end
    
    def assign_class
    end
    
    def data
      if @data.length == 0
        extract
      end    
      @data    
    end
    
# Determine if the this descriptor defines a report where the first prompt is on the current line.
    def recognize?(buffer)
    end
  
  
# TODO prompt needs to be in report. At least the search going through lines.
# Prompt - Look for a passed string or regex and return the line and column position found.
# Options - 
# *  :end_line = last line to look at
# *  :start_line = First line to look at
# *  :prompt_start = returns the location of the first character of the found prompt
# *  :start_column = returns nil if found prior to specified column
# *  :end_column = returns nil if found after specified column
# *  default = returns the location of the character  following the prompt
    def prompt(prompt, options = {})
      prompt = convert_to_regex(prompt, options)
      start_line = 0
      end_line = -1
      start_column = 0
      end_column = 200
      
      end_line = options[:end_line] - 1 unless options[:end_line].nil?
      start_line = options[:start_line] - 1 unless options[:start_line].nil?
      
      start_line = end_line = options[:line] - 1 unless options[:line].nil?
      if start_line < 0 or start_line >= @document.lines.length
        @current_row = nil
        @current_column = nil
        return [nil, nil]
      end
      
      #handle start_column, end_column and specific column
      start_column = options[:start_column] -1 unless options[:start_column].nil?
      end_column = options[:end_column] - 1 unless options[:end_column].nil?
      start_column = end_column = options[:column] - 1 unless options[:column].nil?
      if start_column < 0
        @current_row = nil
        @current_column = nil
        return [@current_row, @current_column]
      end
      
      # regex version
      
      #prompt_regex = convert_to_regex(prompt, options)
      prompt = convert_to_regex(prompt, options) if prompt.class == String
      @document.lines[start_line..end_line].each_with_index do |line, first_prompt_index|
#        @log.debug5 "looking for prompt [#{prompt}] in [#{line}]"
        mtch = prompt.match(line)
        next if mtch.nil?
        if options[:start_of_prompt]
          column = mtch.begin(0)
        else
          column = mtch.end(0)
        end
  
        return [nil, nil] if options[:column] and column != mtch.begin(0)
        return [nil, nil] if options[:start_column] and options[:start_column] >= mtch.begin(0)
        return [nil, nil] if options[:end_column] and options[:end_column] < mtch.begin(0)
        return([@current_row = first_prompt_index + 1, @current_column = column + 1])
      end
      @current_row = nil
      @current_column = nil
      [nil, nil]
    end   
  
  
    
    def first_prompt(prompt, options = {})
      start_line = 0
      end_line = -1
      end_line = options[:end_line] unless options[:end_line].nil?
  
      start_line = options[:start_line] unless options[:start_line].nil?
      @document.lines[start_line..end_line].each_with_index do |line, first_prompt_index|
        return first_prompt_index if line.include?(prompt)
      end
      nil
    end
    
    
# Finds the prompt in the report
# ==== Parameters
# * prompt - the value to look for
# *  :column => should find prompt at a particular column
# ==== Returns
# * row - the row where the prompt is found or nil in not found
# * column - the column where the prompt is found or nil if not found
    def find_prompt_first(prompt, options = {})
      if ((@current_row = first_prompt(prompt, options = {})) == nil)
#        @log.warn "Prompt [#{prompt}] not found."
        @current_column = nil
        return(nil)
      end
      @current_row = @current_row + 1
      @current_line = @document.lines[@current_row - 1]
      @current_column = @current_line.index(prompt) + 1
      [ @current_row, @current_column ] if options[:column].to_i <= @current_column
    end
    
# Find the specfied prompt in the report
# ==== Returns 
# the r/c immediately following the found prompt
    def find_prompt(prompt, options = {})
      if find_prompt_first(prompt, options) 
        @current_column += prompt.length
        return [ @current_row, @current_column ]
      end
      return nil
    end
  
# finds and extracts a field 
# Finds the field using the prompt method
# ==== Parameters
# * prompt_string - The text on the report used to identify the field
# * data_name     - The predefinged data_element 
# * :regex        - flag used to determine if extraction uses regex. If not set uses Text
# * options       - optional hash passed to prompt, extract_regex and extract_text
# ==== Returns
# the extracted value if prompt is found otherwise returns nil  
    def field(prompt_string, data_name, options = {})
      $log.debug "Extracting field #{data_name}"

      if data_element(data_name).nil?
#      unless VALID_DATA_ELEMENTS.has_key?(data_name.to_sym)
        $log.warn "Invalid DataName = [#{data_name}]"
        return nil
      end
   #   binding.pry
      if prompt(prompt_string, options)
        if options[:regex]
          return extract_regex(data_name, options[:regex], options)
        else
          return extract_text(data_name, options)
        end
        post_field(data_name)
      end
      nil
    end
    
# = skip_blanks  
# The skip_blanks method takes moves forward up @current_row and @current_column to 
# a specified number of positions as long as the characters are blank. 
# It returns the row/column of the non blank or nil if all were blank.
# ==== Parameters
# * max_number_of_spaces_to_skip -  Skips up to this number of spaces.
# ==== Returns
# * row       - the row where the first non blank character is found
# * column    - the column of the row where first non blank character is found
    def skip_blanks(number = 200)
      r, c = skip(:blank => true, :number => number)
      if r & c
        [@current_row = r, @current_column = c]
      end
    end
  
# skip columns in a line of text. 
    def skip(options)
      blank = options[:blank]
      max_blanks_to_skip = options[:number]
  #    min = options[:min]  # only valid if :blank
  #    max = options[:max]  # only valid if :blank
      row = options[:row] || @current_row
      column = options[:column] || @current_column
  
      return [nil, nil] if row.nil? or row < 1 or row > @document.lines.length
      line = @document.lines[row - 1] 
      return nil if column < 1 or line.length < column 
      
      if blank
        number_skipped = 0
        max_blanks_to_skip = 200 if max_blanks_to_skip.nil?
        while ((line.length >= column) && !(blank ^ BLANK_CHARS.include?(line[column - 1])) && number_skipped < max_blanks_to_skip)
          column += 1
          number_skipped += 1
        end
      end 
      
      if line.length < column
        return nil
      else
        return [@current_row = row, @current_column = column]
      end
      
    end
    
# Extract_text, strip leading and trailing blanks place the result in results[data_name]
# Usage: extract_text.
#   :row => 3, 
#   :column => 4, 
#   :length => 25, 
#   :ends_with => "Date of" # Upto 25 characters but limit by "Date of"
#   :nostrip => false (default)
# ===== Returns
#    Extracted text
    
    def extract_text(data_name, options = {})
      if data_element(data_name).nil?
#      unless VALID_DATA_ELEMENTS.has_key?(data_name.to_sym)
#        @log.warn "Invalid data extract for data field name [#{data_name.to_s}]"
        puts "Invalid data extract for data field name [#{data_name.to_s}]"
        return nil
      end
      row = options[:row] || @current_row
      row = row + options[:add_rows] unless options[:add_rows].nil?
      @current_row = row
      #can not extract data because row not given probably because prompt not found
      if row.nil?
        return nil
      end 
      row = row - 1
      
      column = options[:column] || @current_column
      column = column + options[:add_columns] unless options[:add_columns].nil?
      column = column - 1 # external is 1 based
      length = options[:length] || data_element(data_name).length

#      length = options[:length] || VALID_DATA_ELEMENTS[data_name.to_sym].length
      ends_with = options[:ends_with]
      line = @document.lines[row]
      field_value = if ends_with
          ends_with = Regexp.escape(ends_with) unless ends_with.class == Regexp
          regexp = Regexp.new(/(.{1,#{200}}?)/.to_s + ends_with.to_s)
          line[(column)..-1] =~ regexp
          $1
        else
          line[(column)..(column + length - 1)]  
        end   
     # puts " field #{data_name} = [#{field_value}]"
#      @log.debug3("field #{data_name} = [#{field_value}]")
      return nil if field_value.nil?   # nothing extracted
      value = process_extract_options(data_name, field_value, options)
      return nil if value.nil?

      @data[data_name] = value 

#      @data[data_name]
    end

    def extract_regex(data_name, regexp, options = {})
      #binding.pry
#      data_name = data_name.to_sym
      if data_element(data_name).nil?
#      unless VALID_DATA_ELEMENTS.has_key?(data_name)
#        @log.warn "Invalid data extract for data field name [#{data_name.to_s}]"
        return nil
      end
   
      row = (options[:row] || @current_row)
      if row.nil?
        return @data[data_name] = ""
      end
      row -= 1
      column = (options[:column] || @current_column) - 1
      #length = VALID_DATA_ELEMENTS[data_name].length
      line = @document.lines[row]
	    $log.debug ("extract_regex: #{line[(column)..-1].match(regexp)}")
      @data[data_name] = line[(column)..-1].match(regexp).andand[0]
    end
    
    def current_location
      [@current_row, @current_column]
    end
    
    def data_element(key)
      self[key.to_sym]
    end

    def set_data(key, v)
      # if key.class.name == 'String'
      #   k = key.to_sym
      # else
      #   k = key
      # end
      # return nil unless Reader::DataElements.has_key?(k)
      #DataElements[k].value = v
      @data[key.to_s] = v
    end

    def get_data(key)
      @data[key.to_s]
    end
    
    def [](key)
      # if key.class.name == 'String'
      #   k = key.to_sym
      # else
      #   k = key
      # end
      DataElements[key.to_sym]
    end
    
    def []=(key, v)
      # if key.class.name == 'String'
      #   k = key.to_sym
      # else
      #   k = key
      # end
      k = key.to_sym
      return nil unless DataElements.has_key?(k)
      DataElements[k].value = v
      @data[k] = v   
    end
    
    private
  
      def process_extract_options(field_name, value, options)
        value = value.strip unless options[:nostrip] == true 
        value = value.downcase  if options[:downcase].nil?  #dhf 7/16/2010 default is upcase
        value = value.upcase unless options[:upcase].nil?
        not_prompt = options[:not]

        unless not_prompt.nil?
          not_prompt  = Regexp.escape(not_prompt) unless not_prompt.class == Regexp
          regx = Regexp.new(not_prompt)

          if regx.match(value)
            return nil
          end
        end
#        @log.debug3 "#{field_name} = [#{value}]"
        value
      end
      
      def convert_to_regex(prompt, options = {})
        if prompt.class == String
          prompt = Regexp.escape(prompt)   
          unless options[:skip_blanks].nil?
            if options[:skip_blanks].class == Integer
                prompt = prompt + "[ ]{0,#{options[:skip_blanks]}}"
            else
              if options[:skip_blanks] =~ /[Nn]o/
                prompt
              else
                prompt = prompt + "[ ]*"
              end
            end
          else
            prompt = prompt + "[ ]*"
          end
          prompt = Regexp.new(prompt)
        end
       # puts "--- Prompt is a regex --- Options: #{options}"
        prompt
      end 
    # End of Private
  end
#end
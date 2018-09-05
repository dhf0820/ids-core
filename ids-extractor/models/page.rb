#module IDSReader
  class Page
    attr_reader :first_line, :last_line
#    @lines = []    #lines of this page
    
  #  def initialize(lines, first_line_offset, last_line_offset)
  #    @first_line = @lines.length
  #    @lines << lines[first_line_offset..last_line_offset]
  #    @last_line = @lines.length - 1
  #  end

# = new
# Creates a new page saving the actuall lines specified as being part of the page.
    def initialize(first_line_offset, last_line_offset, lines = nil)
      @lines = nil
      @first_line = first_line_offset   #offset in orignial buffer
      @last_line = last_line_offset
      @lines = lines.dup unless lines.nil?
#      @lines[lines.length - 1].sub!("\f", "") unless lines.nil?
    end

## = first_line
## Returns the line number of the first line of this page in the original buffer    
#    def first_line
#      @first_line
#    end
#
## = last_line
## Returns the line numner of the last line of this page in the original buffer      
#    def last_line
#      @last_line
#    end

# = line
# Returns the text of the specified line number. If the specified line is invalid, returns nil.    
    def line(line_number)
      return nil if @lines.nil? or @lines.length <= line_number and line_number < 0
      @lines[line_number]
    end

# = lines
# Returns an array of each line on the page. 
    def lines
        @lines
    end
    
    def to_str
      @lines.join("\n")
    end
    
    alias to_s to_str
    
    def to_xml
      "<page>#{to_str}</page>"
    end
    
#  private
#    def first_line=(value)
#      @first_line = value
#    end
#    
#    def last_line=(value)
#      @last_line = value
#    end
    
  end
#end
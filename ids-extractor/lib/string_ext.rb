# Extend string class to provider helper methods to a document line
class String
  def end_of_report?
    case self
      when /\bEnd\s+of\s+Report\b/i
#        puts "Found End of Report"
        true
      when /\bPage\s+(\d+)\s+of\s+(\d+)\b/i
        end_of_document = ($1 >= $2) 
#        puts "Page #{$1} of #{$2} End of report #{end_of_document}"
        end_of_document 
      when /[cC]ontinued [nN]ext [pP]age/
        false
#      when /\x0c/
#        true
      else
        false
    end
  end

  def report_end?(value)
    false
  end
  
  def contains_form_feed?
    return self.include?("\f")
  end
  
  def first_page_of_report?
    return true if self =~ /\bPage\s+1\b/i # Page 1 not Page 10
    false
  end
end
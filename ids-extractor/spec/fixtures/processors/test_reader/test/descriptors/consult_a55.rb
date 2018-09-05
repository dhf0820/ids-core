class ConsultA55 < Reader::Descriptor
    
    def self.title
      "Consultation Report A55"
    end

    def title
      "Consult A55"
    end
    def self.recognize?(document)
      document.first_identifier?("Healing Hands", :line => 2) and
      document.other_identifier?("S ainJ oseph’H ospital Aftlanta", :line => 0) and
      document.other_identifier?("Consultation Report A55", :line => ['page'])
      #(document.other_identifier?("PHYSCIAL", :lines => [7, 11, 50, 51]) or
      # document.other_identifier?("Physical", :line => 8))
    end
     
    # Determine if the current page is the end of the document Not being used right now
    def end_of_report?(document)
      document
    end
    
    #! refactor to just use name of field and call extract so this code will not be needed 
    # could then override extract to do post processing
    def extract
      extract_all
  #   extract_patient_name
  #   extract_mrn
  #   extract_acct_num
  #   extract_pcp
  #   extract_ssn
  #   extract_admit_date
      extract_ccs
    end
    
  #  def post_process(pages)
  #    remove_top_lines 5
  #    remove_bottom_lines 3
  #    puts "in Post Process"
  #  end
  
  #  Override if   need to drop this report as not needed
  #  def status  
  #    :process   # :process, :drop
  #  end
  
  # def cleanup(pages)
  #   do what is needed to clean up report.
  #   remove/trim lines, etc
  #    remove_top_lines 5
  #    remove_bottom_lines 3
  # end
  
    def assign_class
	    puts "ASSIGNING CLASS"
	    #data_element(:report_type, 'Rad-101')
	    #self['report_type']='Rad-101'
	    #set_data('report_type', 'Rad-101')
	    #set_data('report_class', 'Radiology')
      #report_class = "Radiology"  # not needed if type is structured like below. Rad is class and type is 101
      report_type =  "Rad-101"
      report_class = "Radiology"  # not needed if type is structured like below. Rad is class and type is 101


    end
    
    def add_data_elements
    end
  
  private
  
    def extract_all
      field("PATIENT:", "pat_name",  :ends_with => 'SSN')
      field("M.R. NUMBER:", 'mrn', :regex => /\d+/)
      field("DATE OF REPORT:", 'date_of_report', add_rows:1, :start_of_prompt => true )
      # field("DATE OF ADMISSION:[ ]*", "admit_date")
      field("CONSULTING PHYSICIAN:", 'ordering_physician', :upcase => true)
      #field("PRIMARY CARE PHYSICIAN:", "pcp", :start_of_prompt => true, :add_rows => 1, :length => 25, :upcase => true)
      field("ACCOUNT NUMBER:", "acct_num", :regex => /\d+/ )
      field("Doc #:", "doc_id", :regex => /\d+/ )
    end
    
    def extract_patient_name
      # Find the prompt and return the r/c after end
  #    r, c = prompt("PATIENT:", :skip_blanks => "all")
  #   extract_text "pat_name",
  #     :row => r, 
  #     :column => c, 
  #     :ends_with => "SSN: " # limit by "SSN:"
      field("PATIENT:", "pat_name", :ends_with => "SSN:")
    end
    
    def extract_mrn
      field("M.R. NUMBER:", 'mrn', :regex => /\d+/ )
  #    r, c = find_prompt('M.R. NUMBER:')
  #    skip_blanks(8)
  #    extract_regex('mrn', /\d+/) # Uses internal last row/column
    end
    
    def extract_ssn
      field("SSN:", "ssn")
    end
    
    def extract_admit_date
      field("DATE OF ADMISSION:[ ]*", "admit_date")
    end
    
    def extract_acct_num
      prompt("ACCOUNT NUMBER:")
      skip_blanks(8)
      extract_text("acct_num") # Extracts the default number of characters
  # could substitute
  #    field("ACCOUNT NUMBER:", "acct_num")
    end
    
    def extract_pcp
      field("PRIMARY CARE PHYSICIAN:", "pcp", :start_of_prompt => true, :add_rows => 1, :length => 25, :upcase => true)
  #    r, c = find_prompt_first("PRIMARY CARE PHYSICIAN:") # returns the row column of the first letter of the prompt
  #    extract_text('pcp', 
  #      :row => r + 1,  # or :add_rows => 1
  #      :column => 1,
  #      :length => 25
  #    )  # extracts starting at the next line first column for up to 25 characters
    end
    
    def extract_ccs
      r, c = prompt("cc:")
      extract_text("cc1", :add_rows => 0)
      extract_text("cc2", :add_rows => 1, :column => 1) #current_row will now is the rowof this extract
      # should we keep the row of the prompt return value
      extract_text("cc3", :add_rows => 1, :column => 1)

    end
  end
#end

  class SampleDescriptor < Descriptor
    
    def self.title
      "Basic Sample Descriptor"
    end
    
    def self.recognize?(document)
      document.first_identifier?("EMERGENCY DEPARTMENT VISIT", :line => 2) and
      document.other_identifier?("Care Provider", :line => 6)  #really is line 5 but test is to fail
    end
    
    def extract
    	extract_patient_name
    	extract_patient_MRN
    	extract_patient_acct
    	extract_pcp
    	extract_cc
    end
  
    private
  
      def extract_patient_name
        field("Patient Name:", "pat_name", :ends_with => "Date of", :length => 25)
        # Find the prompt and return the r/c after end
#      	r, c = find_prompt("Patient Name:")			
#      	r, c = skip_blanks(3)
#      	extract_text "patient_name", 
#      	  :row => r, 
#      	  :column => c, 
#      	  :length => 25, 
#      	  :ends_with => "Date of" # Upto 25 characters but limit by "Date of"
      end
  
      def extract_patient_MRN
        field("Med Rec #:", 'mrn', :regex => /\S*\d+/ )
      end
  
      # Returns an array cc objects of all found    	
      def extract_pcp
        field("PRIMARY CARE PHYSICIAN", "pcp")
#      	r, c = find_prompt_first "PRIMARY CARE PHYSICIAN"
#      	extract_text "pcp", :row => r + 1, :length => 20 if r
      end
  
      def extract_patient_acct
        field("Account #: ", :account_num)
#      	find_prompt_blanks("Account #:")
#      	skip_blanks(3)
#      	extract_text :account_num, :length => 7
      end
  
      def extract_cc
      	r, c = find_prompt "Doc #:"
      	r, c = find_prompt "cc:", :row => r + 1
      end
  end

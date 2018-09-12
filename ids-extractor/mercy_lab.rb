
  class MercyLab < Descriptor
    
    def self.title
      "Mercy Lab Test"
    end

    def title
	    "Mercy Lab Test"
    end
    
    def self.recognize?(document)
      document.first_identifier?("MERCY MT.SHASTA", :line => 2) and
      document.other_identifier?("CLINICAL LABORATORY", :line => 5)  #really is line 5 but test is to fail
	  document.other_identifier?("INTERIM REPORT", :line => 63)
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
        field("NAME:", "pat_name", :ends_with => "DR:", :length => 30)
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
        field("MR#", 'mrn', :regex => /\d+/ )
      end
  
      # Returns an array cc objects of all found    	
      def extract_pcp
        field("PHYS:", "pcp")
#      	r, c = find_prompt_first "PRIMARY CARE PHYSICIAN"
#      	extract_text "pcp", :row => r + 1, :length => 20 if r
      end
  
      def extract_patient_acct
        field("ACCOUNT #:", :account_num)
#      	find_prompt_blanks("Account #:")
#      	skip_blanks(3)
#      	extract_text :account_num, :length => 7
      end
  
      def extract_cc
      	# r, c = find_prompt "Doc #:"
        # 
      	# r, c = find_prompt "cc:", :row => r + 1
      end
  end

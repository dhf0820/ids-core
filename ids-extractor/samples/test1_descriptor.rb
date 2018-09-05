
  class Test1Descriptos < Reader::Descriptor
    
    def self.title
      "Test1 Descriptor"
    end

    def title
      "Test1 Descriptor"
    end
    
    def self.recognize?(document)
      document.first_identifier?("EMERGENCY DEPTMENT VISIT", :line => 2) and
      document.other_identifier?("Care Provider", :line => 6) 
    end
    
    def extract
    	extract_patient_name
    	extract_patient_MRN
    	extract_patient_acct
    	extract_pcp
    	field("EMERGENCY DEPARTMENT VISIT --", :subclass, :length => 25)
#    	extract_cc
    end

    def assign_class
#puts "Assigning a new Subclass = #{data_element(:subclass).name}"
      data_element(:class).value = '1000'
      self[:class] = '1000'
      # data_element
    end
    
    def add_data_elements
      Reader::DataElements[:subclassid] = Reader::DataElement.new('subclassid', 11, :alphanumeric)
      Reader::DataElements[:class] = Reader::DataElement.new('class', 11, :alphanumeric)
      # if special data elements are required for this particular report they can be added here
    end  
    private
  
      def extract_patient_name
        field("Patient Name:", :pat_name, :ends_with => "Date of", :length => 25)
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
        field("Med Rec #:", 'mrn', :regex => /\S+/ )
      end
  
      # Returns an array cc objects of all found    	
      def extract_pcp
        field("PRIMARY CARE PHYSICIAN", "pcp")
#      	r, c = find_prompt_first "PRIMARY CARE PHYSICIAN"
#      	extract_text "pcp", :row => r + 1, :length => 20 if r
      end
  
      def extract_patient_acct
        field("Account #:", :acct_num)
#      	find_prompt_blanks("Account #:")
#      	skip_blanks(3)
#      	extract_text :account_num, :length => 7
      end
  
      def extract_cc
      	r, c = find_prompt "Doc #:"
      	r, c = find_prompt "cc:", :row => r + 1
      end
  end

class ConsultA55 < Descriptor

  def self.title
    'Consultation A55'
  end

  def title
    'Consultation A55'
  end

  def self.recognize?(document)
    document.first_identifier?('Healing Hands', :line => 2) and
      document.other_identifier?('S ainJ oseph’H ospital Aftlanta', :line => 0) and
      document.other_identifier?('Consultation Report A55', :line => ['page'])

  end

  # Determine if the current page is the end of the document Not being used right now
  def end_of_report?(document)
    document
  end

  #! refactor to just use name of field and call extract so this code will not be needed
  # could then override extract to do post processing
  def extract
    extract_all
    extract_ccs
  end



  def assign_class
    puts 'ASSIGNING CLASS'
    #data_element(:report_type, 'Rad-101')
    #self['report_type']='Rad-101'
    set_data('report_type', '2001')
    set_data('report_class', '0200')
    report_class = "0200"  # not needed if type is structured like below. Rad is class and type is 101
    report_type =  '2001'

  end

  def add_data_elements
    puts 'ASSIGNING DATA ELEMENTS '
    #self['report_class'] = 'Radiology'
    # if special data elements are required for this particular report they can be added here
  end

  private

  def extract_all
    field('PATIENT:', 'pat_name',  :ends_with => 'SSN', :upcase => true)
    field('M.R. NUMBER:', 'mrn', :regex => /\d+/)
    field('DATE OF REPORT:', 'rept_date')
    # field('DATE OF ADMISSION:[ ]*', 'admit_date')
    val = field('CONSULTING PHYSICIAN:', 'generating', :upcase => true)
    #field('PRIMARY CARE PHYSICIAN:', 'pcp', :start_of_prompt => true, :add_rows => 1, :length => 25, :upcase => true)
    field('ACCOUNT NUMBER:', 'acct_num', :regex => /\d+/ )
    val = field('Doc #:', 'doc_ref', :regex => /\d+/ )
    field(/^T:\s/, 'transcribed_date' )
  end

  def extract_ccs
    r, c = prompt('cc:')
    extract_text('cc1', :add_rows => 0)
    extract_text('cc2', :add_rows => 1, :column => 1) #  @current_row will now is the rowof this extract
    # should we keep the row of the prompt return value
    extract_text('cc3', :add_rows => 1, :column => 1)
  end
end
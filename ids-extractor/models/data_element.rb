
#module IDSReader
  class DataElement
    attr_accessor :length, :name, :element_type, :value, :picture
    
    def initialize(name, length, element_type, picture = nil)  #these problably be hash elements

      self.name = name
      self.length = length
      self.element_type = element_type
      self.picture = picture
      self.value = nil
    end

    
  end
#end

#VALID_DATA_ELEMENTS = {
#  :pat_name =>    Reader::DataElement.new('pat_name', 30, :alphanumberic, true),
#  :acct_num =>    Reader::DataElement.new('acct_num', 12, :numeric, true),
#  :mrn =>         Reader::DataElement.new('mrn',  8, :numeric, true),
#  :pcp =>         Reader::DataElement.new('pcp', 30, :alphanumeric, true),
#  :cc1 =>         Reader::DataElement.new('cc1', 30, :alphanumeric, true),
#  :cc2 =>         Reader::DataElement.new('cc2', 30, :alphanumeric, true),
#  :cc3 =>         Reader::DataElement.new('cc3', 30, :alphanumeric, true),
#  :dob =>         Reader::DataElement.new('dob', 10, :date, true),
#  :ssn =>         Reader::DataElement.new('ssn', 11, :alphanumeric, true),
#  :admit_date =>  Reader::DataElement.new('admit_date', 10, :date, true)
#}
#require File.dirname(__FILE__) + '/../../spec_helper.rb'
config_path = File.dirname(__FILE__) + "/../../fixtures/test_reader.yml"

describe DataElements do
  # before :each do
  #   @field1 = IDSReader::DataElements['master_field1'] =IDSReader::DataElement.new('MasterField1', 11, :alphanumeric, true)
  #   @field2 = IDSReader::DataElements['master_field2'] =IDSReader::DataElement.new('MasterField2', 12, :alphanumeric, true)
  #   @field3 =IDSReader::DataElements['master_field3'] =IDSReader::DataElement.new('MasterField3', 113, :alphanumeric, true)
  #   @field4 =IDSReader::DataElements['temp_field4'] =IDSReader::DataElement.new('TempField4', 114, :alphanumeric)
  # end
  #
  # it "should find a DataElement by name" do
  #  IDSReader::DataElements['master_field1'].should == @field1
  #  IDSReader::DataElements['temp_field4'].should == @field4
  # end
  #
  # it "should mark a field as master" do
  #   expect(Reader::DataElements['master_field1'].master).to be true
  #   expect(Reader::DataElements['temp_field4'].master).to be false
  # end
  #
  # it "should clear all temp fields" do
  #  IDSReader::DataElements.clear
  #   expect(Reader::DataElements['temp_field4']).to be nil
  # end
  
end
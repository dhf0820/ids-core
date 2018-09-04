
#require 'spec_helper'
require './models/document_type'
require './models/document_class'
require './spec/factories/document_type'
require './spec/factories/document_class'


RSpec.describe DocumentType, type: :model do
	before :each do
	end

	it 'should find DocumentType by code' do
		con = FactoryBot.build(:con_1)
		con_class = FactoryBot.build(:con_cls)
		con_class.save
		con_class.add_type(con)
		expect(DocumentType.by_code('con_1').id).to eql(con.id)
	end
end

require 'spec_helper'
require './models/document_type'
require './models/document_class'
require './spec/utilities/test_setup'
require './models/ids_error'
require './models/app_environment'
require './models/customer_environment'

require './models/remote_repository'

# require './spec/factories/document_type'
# require './spec/factories/document_class'


RSpec.describe DocumentType, type: :model do
	before :each do
		@ts = TestSetup.new
		@ts.create_environment
		#@im = ImageManager.new
	end

	it "Should load a DocumentType from remote" do
		type = DocumentType.load_type(56)
		expect(type.remote_id).to eql '56'
		expect(DocumentType.count).to eql 1
	end

	it "Should load all DocumentTypes from remote" do
		types = DocumentType.load_types
		expect(types.count).to eql 56
		expect(DocumentType.count).to eql 56
		dt = DocumentType.by_code('ConsultA55')
		expect(dt.code).to eql 'ConsultA55'
		expect(dt.remote_id).to eql '56'
	end

	it "Should create DocType and add it self to its DocClass" do
		type = DocumentType.load_type(56)
		dc= DocumentClass.find(type.document_class[:ids_id])
		expect(dc.code).to eql '0300'
	end
	# it 'should find DocumentType by code' do
	# 	con = FactoryBot.build(:con_1)
	# 	con_class = FactoryBot.build(:con_cls)
	# 	con_class.save
	# 	con_class.add_type(con)
	# 	expect(DocumentType.by_code('con_1').id).to eql(con.id)
	# end
end
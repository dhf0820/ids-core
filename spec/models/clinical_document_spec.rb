require 'spec_helper'
require './models/document_type'
require './models/document_class'
require './spec/utilities/test_setup'
require './models/ids_error'
require './models/app_environment'
require './models/customer_environment'

require './models/remote_repository'
require './models/clinical_document'



RSpec.describe ClinicalDocument, type: :model do

	before :each do
		@ts = TestSetup.new
		@ts.create_environment
		#@im = ImageManager.new
	end

	it 'should load a ClinicalDocument by remote_id' do
		c_doc = ClinicalDocument.by_remote_id(41)
		expect(c_doc.remote_id).to eql '41'
		expect(c_doc.patient['name']).to eql 'French, Theresa E.'
	end


	it 'should create a remote document' do
		DocumentType.load_types
		doc_type = DocumentType.by_code('1102')
		pat = @ts.create_patient
		pat.update_remote
		c_doc = ClinicalDocument.new
		#visit = @ts.create_visit
		c_doc.doc_ref = '1299'
		c_doc.rept_date = DateTime.now
		c_doc.recv_date = DateTime.now
		c_doc.type_info = doc_type.summary
		c_doc.patient = pat.summary
		c_doc.facility = 'pphs'
		c_doc.image = File.read('./spec/samples/doc-lab1.pdf')


	end
end


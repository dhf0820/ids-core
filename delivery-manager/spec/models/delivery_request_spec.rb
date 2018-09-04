require 'rspec'
#require './spec_helper'
require './spec/utilities/delivery_setup'
require './models/mail_delivery_class'
require './models/mail_delivery'
require './models/delivery_manager'
require './models/delivery_request'
require './models/patient'
require './models/visit'
require './models/clinical_document'



RSpec.describe DeliveryManager, type: :model do

	before :context do
		@ds = DeliverySetup.new
		@ds.create_environment
		@ds.create_rabbit
		@doc_class = @ds.document_class_type('consult')

		@doc_type = DocumentType.find @doc_class.document_types[0][:ids_id]
		@type_info = {id: @doc_type.id, code: @doc_type.code, class_id: @doc_type.document_class[:id],
		              class_code: @doc_type.document_class[:code]}
		@tefrench = @ds.create_patient
		@visit = @ds.create_visit('tfv1234', @tefrench)
		@clin_doc = @ds.clinical_document(@tefrench, @visit, @type_info)


		@prac = @ds.create_fax_practice
		@raw = RawName.lookup(@prac.full_name)
		@dm = DeliveryManager.new
		#, type_id: @doc_class.document_types[0][:id])
	end



	it 'should process a new delivery request' do
		@dm.queue_delivery(@raw, @clin_doc, 'cc')
	end
end
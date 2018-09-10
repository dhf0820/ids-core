require 'spec_helper'
require '../sys_models/chart_archive_class'
require '../sys_models/chart_archive_delivery'
require '../sys_models/patient'
require '../sys_models/practice'
require '../sys_models/clinical_document'
require '../sys_models/raw_name'
#require './spec/factories/fax_class'
require './spec/utilities/test_setup'



RSpec.describe ChartArchiveDelivery, type: :model do
	before :all do
    @ds = TestSetup.new
    @config = Config.active
  end


	it "should create only one default ChartArchive delivery" do
		cad = ChartArchiveDelivery.default
		expect(ChartArchiveDelivery.default.id).to eql ChartArchiveClass.default_device.id
	end

	describe 'delivery queueing', focus: true do
		before :context do
			@ds = TestSetup.new
      @doc_class = @ds.document_class_type('consult')
   
			@doc_class.save
			@tefrench = @ds.create_patient
			@visit = @ds.create_visit('tfv1234', @tefrench)
			@doc_type = DocumentType.find @doc_class.document_types[0][:ids_id]
			@type_info = {id: @doc_type.id, code: @doc_type.code, class_id: @doc_type.document_class[:ids_id],
			              class_code: @doc_type.document_class[:code]}

			@clin_doc = @ds.clinical_document(@tefrench, @visit, @type_info)

      @prac =Practice.new
      @prac.name = "Test Practice"
      @prac.save
      @raw = RawName.lookup(@prac.full_name)
		end

		it 'should queue a document for delivery to nightly print' do
      dev = ChartArchiveClass.default_device #@prac.get_primary
      qr = dev.queue(@clin_doc, @prac)
      qr = DeliveryRequest.first
			expect(qr.device_id).to eql dev.id.to_s
			expect(qr.device_class_id).to eql dev.delivery_class_id.to_s
		end
	end

end
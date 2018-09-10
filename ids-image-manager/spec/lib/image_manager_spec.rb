#require 'rails_helper'
require 'spec_helper'
require './lib/image_manager'


require '../sys_lib/work_queue'

require './spec/utilities/test_setup'
require '../sys_models/ids_error'
require '../sys_models/app_environment'
require '../sys_models/customer_environment'
require '../sys_models/document_type'
require '../sys_models/remote_repository'
#require '../sys_models/chart_archive_class'
require '../sys_models/chart_archive_delivery'

RSpec.describe ImageManager, type: :model do

	before :each do
		@ts = TestSetup.new
		#@ts.create_environment
    @im = ImageManager.new
    @config = Config.active
    @remote = @config.remote

		DocumentType.load_types
	end

	it 'should process an unknown message type' do
		data = {}
		data['image'] = File.read('./spec/samples/doc-lab1.pdf')
		data['source'] = 'MMS-LAB'
    data['job_id'] = '123'
    data['pat_name'] = 'Theresa French'
		data['mrn'] = 'tf1015'
    data['received_date'] = '07/06/2018 2114'
    
		@im.process_unknown(data)
		expect(UnknownDocument.all.count).to eql 1
	end

	it "Should process an existing patient", focus: true do
    data = {}
    data['image'] = File.read('./spec/samples/doc-lab1.pdf')
		data['source'] = 'MMS-LAB'
    data['job_id'] = '123'
		data['pat_name'] = 'Theresa French'
    data['mrn'] = 'tf1015'
    data['report_type'] = 'TEST_IPLAB' #'TEST_IPLAB'
		data['doc_ref'] ='999-1'
    data['facility'] = 'pphs'
		pat = @im.process_patient(data)
		expect(pat.new_record?).to be false
  end

  it "Should process a delivery_request to ChartArchive" do
    data = {}
    data['image'] = File.read('./spec/samples/doc-lab1.pdf')
		data['source'] = 'MMS-LAB'
    data['job_id'] = '123'
		data['pat_name'] = 'Theresa French'
    data['mrn'] = 'tf1015'
    data['report_type'] = 'TEST_IPLAB' #'TEST_IPLAB'
		data['doc_ref'] ='999-1'
		data['facility'] = 'pphs'
    pat = @im.process_patient(data)
    
		expect(pat.new_record?).to be false
	end


	it "Should process a new patient" do  #Should really come through HL/7 however need t create basic if none
		data = {}
		data['pat_name'] = 'Lacey LaCour'
		data['mrn'] = 'll0819'
    pat = @im.process_patient(data)
    expect(pat.new_record?).to be false
		#expect(pat.remote_id).to_not be_nil
    visit = @im.process_visit(data, pat)
    expect(visit.new_record?).to be false
		#expect(visit.remote_id).to_not be_nil
	end

	it "Should process a new visit" do  #Should really come through HL/7 however need t create basic if none
		data = {}
		data['pat_name'] = 'Lacey LaCour'
		data['mrn'] = 'll0819'
		pat = @im.process_patient(data)
		#binding.pry
		expect(pat.new_record?).to be false
		visit = @im.process_visit(data, pat)
		#expect(visit.remote_id).to_not be_nil

	end

	it "Should add a ClinicalDocument" do
		data = {}
		data['pat_name'] = 'Lacey LaCour'
		data['mrn'] = 'll0819'
		data['report_type'] = 'TEST_IPLAB' #'TEST_IPLAB'
		data['doc_ref'] ='999-1'
		data['facility'] = 'pphs'
		pat = @im.process_patient(data)
		visit = @im.process_visit(data, pat)
		image = File.read('./spec/samples/doc-lab1.pdf')
		qd = @im.add_document(data, image, pat, visit)
		expect(qd['doc_id']).to_not be_nil
	end

	it "Should add a ClinicalDocument" do
		data = hash =  HashWithIndifferentAccess.new
		data['pat_name'] = 'Lacey LaCour'
		data['mrn'] = 'll0819'
		data['report_type'] = 'TEST_OPLAB' #'TEST_IPLAB'
		data['doc_ref'] ='999-2'
		data['facility'] = 'pphs'
    data['image'] = File.read('./spec/samples/doc-lab1.pdf')
    start_time = Time.now
    qd = @im.process_job( data)
    puts "Process Job elapsed time: #{(Time.now - start_time).in_milliseconds}ms\n"
		expect(qd[:doc_id]).to_not be_nil
		#puts "\n\nqd: #{qd}"


	end
end
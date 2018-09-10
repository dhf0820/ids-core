
require '../sys_models/document_class'
require '../sys_models/document_type'
require '../sys_models/clinical_document'
require '../sys_models/patient'
require '../sys_models/visit'
require '../sys_models/app_environment'
require '../sys_models/customer_environment'
require '../sys_models/fax_class'
#require '../sys_models/remote_repository'

require './models/config'
class TestSetup


	ENV['SERVICE'] = 'image_manager'
	ENV['CUSTOMER'] = 'test'
	ENV['TESTING'] = 'true'
	ENV['MONGO_ENV'] = 'test'

	# Should not need this as it is in db config
	#
  ENV['AMQP'] = 'amqp://cnctocwk:q8w3LU-Msi2Zpt-rL9sVXRcz-e8kdMSQ@donkey.rmq.cloudamqp.com/cnctocwk'
  
  def initialize
    super
    create_environment
  end

	def create_environment

		$cust_env = CustomerEnvironment.new
		$cust_env.customer = ENV['CUSTOMER']
		$cust_env.process = 'system'
		$cust_env.amqp = ENV['AMQP']
		$cust_env.remote_url = 'https://chartarchive.herokuapp.com/api/v2'
		$cust_env.remote_token = 'My1Love!Enyedi!'

		$cust_env.save

		$app_env = AppEnvironment.new
		$app_env.customer = ENV['CUSTOMER']
		$app_env.process = ENV['SERVICE']
		$app_env.out_queue_name = 'dispatch_queue'
		$app_env.in_queue_name = 'archive_queue'
		$app_env.error_queue_name = 'ids.image_error'
		$app_env.app_name = 'test_image'
		$app_env.log_topic = 'img'
    $app_env.log_key  = 'img'
    env = $app_env.environment
    env[:unknown_queue_name] = 'unknown'
		$app_env.save
		$app_env

    @config = Config.new
		# $remote = RemoteRepository.new

		# $connection = Bunny.new($cust_env.amqp)
    # $connection.start

	end

	def create_rabbit
		# $connection = Bunny.new($cust_env.amqp)
		# $connection.start

	end


	def create_patient
		pat = Patient.new
		pat.first_name = 'Theresa'
		pat.middle_name = 'E.'
		pat.last_name = 'French'
		pat.mrn = 'te1015'
		pat.ssn = '123-45-6789'
		pat.birth_date = Date.strptime('10/15/1957', '%m/%d/%Y')
		pat.save
		pat
	end

	def create_visit(num, pat)
		v = Visit.new
		v.number = num
		v.admit_date = DateTime.now
		v.facility = 'TEST'
		v.remote_id = 18
		pat.add_visit v
		v
	end



	def document_class_type(class_code)
		dc = DocumentClass.new(code: class_code, description: "#{class_code} Description")
		dc.save
		(1..3).each do |n|
			code = "#{class_code}-#{n}"
			dt = DocumentType.new(code: code, description: "#{code} Description")
			dc.add_type(dt)
    end
    dc.save
		dc = DocumentClass.find dc.id
	end

	def document_code(code, description)
		dc = DocumentClass.new
		dc.code = code
		dc.description = description
		dc.save
	end

	def document_type(class_code, type_code)
		dc = DocumentClass.by_code(class_code)
		dt = DocumentType.new
		dt.code = type_code
		dt.document_class = dc.summary
		dt.save
	end

	#  add a real visit
	def clinical_document(pat, visit, type_info)
		cdoc = ClinicalDocument.new()
		cdoc.patient = pat.summary
		cdoc.visit = visit.summary
		cdoc.remote_id = 23
		cdoc.type_info = type_info #{type_id: doc_type.id, type_code: doc_type.code, class_id: doc_type.document_class[:id], class_code: doc_type.document_class[:code]}
		#cdoc.rep_type
		cdoc.save
		# dv = DocumentVersion.new
		# dv.clinical_document_id = cdoc.id
		# dv.version_number = 1
		# dv.save
		cdoc
	end


end
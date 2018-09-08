
require './models/app_environment'
require './models/customer_environment'

class TestSetup


	ENV['SERVICE'] = 'reader'
	ENV['CUSTOMER'] = 'test'
	ENV['TESTING'] = 'true'
	ENV['MONGO_ENV'] = 'test'

	# Should not need this as it is in db config
	#
	ENV['AMQP'] = 'amqp://cnctocwk:q8w3LU-Msi2Zpt-rL9sVXRcz-e8kdMSQ@donkey.rmq.cloudamqp.com/cnctocwk'
	#ENV['AMQP'] = nil
	def create_environment

		$cust_env = CustomerEnvironment.new
		$cust_env.customer = ENV['CUSTOMER']
    $cust_env.process = 'system'
  
		env = $cust_env.environment
		env['amqp']  = ENV['AMQP']
		$cust_env.remote_url = 'https://chartarchive.herokuapp.com/api/v2'
		$cust_env.remote_token = 'My1Love!Enyedi!'


		$cust_env.save

		$app_env = AppEnvironment.new
		$app_env.customer = ENV['CUSTOMER']
    $app_env.process = ENV['SERVICE']
    $app_env.in_queue_name = 'test'
    $app_env.out_queue_name = 'archive'
    $app_env.app_name = 'test_reader'
    $app_env.log_topic = 'rdr'
    $app_env.log_key = 'test_rdr'
    $app_env.app_name = 'test_reader'

		env = $app_env.environment
		#env['out_queue'] = 'archive_queue'
		#env['in_queue'] = 'rad'
		#$app_env.error_queue = 'ids.reader_error'
		#env['app_name'] = 'test_reader'
		#env['log_topic'] = 'rdr'
		#env['log_key']  = 'test_rdr'
		env['descriptor_keys'] = ['consult_a55', 'mercy_lab', 'sample_descriptor']
		$app_env.save
		$app_env

		#$remote = RemoteRepository.new


	end

	def create_rabbit
		$connection = Bunny.new($cust_env.amqp)
		$connection.start

	end

	def create_data_dictionary
		t = DataDictionary.new
		t.name = 'pat_name'
		t.length = 30
		t.element_type = :alphanumeric
		t.save

		t = DataDictionary.new
		t.name = 'acct_num'
		t.length = 12
		t.element_type = :numeric
		t.save

		t = DataDictionary.new
		t.name = 'mrn'
		t.length = 8
		t.element_type = :numeric
		t.save

		t = DataDictionary.new
		t.name = 'pcp'
		t.length = 30
		t.element_type = :alphanumeric
		t.save

		t = DataDictionary.new
		t.name = 'cc1'
		t.length = 30
		t.element_type = :alphanumeric
		t.save

		t = DataDictionary.new
		t.name = 'cc2'
		t.length = 30
		t.element_type = :alphanumeric
		t.save

		t = DataDictionary.new
		t.name = 'dob'
		t.length = 10
		t.element_type = :date
		t.save

		t = DataDictionary.new
		t.name = 'rept_date'
		t.length = 10
		t.element_type = :date
		t.save

		t = DataDictionary.new
		t.name = 'ssn'
		t.length = 30
		t.element_type = :alphanumeric
		t.picture = '/\d{3}-?\d{2}-?\d{4}/'
		t.save

	end

	def create_definitions
		a55 = DocumentDef.new
		a55.definition = File.open('./samples/consult_a55.rb', "r").read
		a55.name = 'consult_a55'
		a55.document_type = 'ConsultA55'
		a55.save

		ml = DocumentDef.new
		ml.definition = File.open('./samples/mercy_lab.rb', "r").read
		ml.name = 'mercy_lab'
		ml.document_type = "1001"
		ml.save

		sd = DocumentDef.new
		sd.definition = File.open('./samples/sample_descriptor.rb', 'r').read
		sd.name = 'sample_descriptor'
		sd.document_type = '9000'
		sd.save


		td = DocumentDef.new
		td.definition = File.open('./samples/test1_descriptor.rb', 'r').read
		td.name = 'test1_descriptor'
		td.document_type = '9002'
		td.save
	end
end
require './models/delivery_profile'
require './models/document_class'
require './models/document_type'
require './models/delivery_class'
require './models/delivery_device'
require './models/clinical_document'
require './models/patient'
require './models/visit'
require './models/document_version'
require './models/practice'
require './models/physician'
require './models/raw_name'
require './models/user'
require './models/app_environment'
require './models/customer_environment'
require './models/remote_repository'
#require './models/guid'

class DeliverySetup

	@@practices = {}

	# def initialize
	# 	create_practices()
	# end

	ENV['SERVICE'] = 'dm_test'
	ENV['CUSTOMER'] = 'test'
	ENV['TESTING'] = 'true'
	ENV['AMQP'] = 'amqp://cnctocwk:q8w3LU-Msi2Zpt-rL9sVXRcz-e8kdMSQ@donkey.rmq.cloudamqp.com/cnctocwk'
	def create_environment

		$cust_env = CustomerEnvironment.new
		$cust_env.customer = ENV['CUSTOMER']
		$cust_env.process = 'system'
		$cust_env.amqp = ENV['AMQP']
		env = $cust_env.environment
		env['code_length'] = 6
		$cust_env.remote_url = 'https://chartarchive.herokuapp.com/api/v2'
		$cust_env.remote_token = 'My1Love!Enyedi!'

		$cust_env.save

		$app_env = AppEnvironment.new
		$app_env.customer = ENV['CUSTOMER']
		$app_env.process = ENV['SERVICE']
		$app_env.out_queue_name = 'test_delivery'
		$app_env.in_queue_name = 'test_dispatch'
		$app_env.app_name = 'test_disp'
		$app_env.log_key  = 'test_disp'
		$app_env.save
		$app_env
    @config = Config.new
		$remote = RemoteRepository.new


	end

	# def create_rabbit
	# 	$connection = Bunny.new($cust_env.amqp)
	# 	$connection.start

	# end



	#Setup one practice with primary = Mail
	#      one practice with primary = Fax
	#      One Practice with primary = Athena
	def create_practices()
		@@practices[:mail] = create_mail_practice()
		@@practices[:none]   = create_none_practice()
		@@practices[:fax]    = create_fax_practice()
		#@practices[:athena] = create_athena_practice()
	end

	def create_mail_practice()
		prac = Practice.new()
		prac.name = "NightMail Practice"
		prac.save
		puts "Create Mail Practices"
		RawName.create_raw_name(prac.summary)
		prac
	end

	def create_none_practice()
		none = NoDeliveryClass.default
		prac = Practice.new
		prac.primary_device= NoDelivery.default.summary
		prac.name = "Practice receiving Nothing"

		prac.owner_context = 'pra'
		prac.save
		RawName.create_raw_name(prac.summary)
		prac
	end

	def create_fax_practice()
		prac = Practice.new
		prac.name = "Practice fax"
		prac.owner_context = 'pra'
		prac.save
		of = create_fax_device(prac.summary)
		prac.add_device(of, true)
		# prac.primary_delivery_device_id = of.id
		# prac.primary_delivery_class_id = of.class_id
		prac.save
		#@@practices[:fax] = pra_fax
		RawName.create_raw_name(prac.summary)
		prac
	end

	def create_practice()
		prac = Practice.new
		prac.name = "My Practice"
		prac.owner_context = 'pra'
		prac.save
		#@@practices[:fax] = pra_fax
		RawName.create_raw_name(prac.summary)
		prac
	end

	def create_fax_device(owner)
		of = FaxDevice.new
		of.delivery_class_id = FaxClass.default.id
		of.owner = owner
		of.name = "Office Fax"
		of.description = "Office Fax"
		of.fax_number = "855-810-0810"
		of.save
		of
	end



	def self.practices
		@@practices
	end

	def setup_for_delivery

		#DocType
		#Patient
		# Visit
		# ClinicalDocument
		# Practice
		# DeliveryProfile
		#
	end

	def create_patient
		pat = Patient.new
		pat.first_name = 'Theresa'
		pat.middle_name = 'E.'
		pat.last_name = 'French'
		pat.mrn = 'te1015'
		pat.ssn = '123-45-6789'
		pat.birth_date = Date.strptime('10/15/1957', '%m/%d/%Y')
		pat.remote_id = 12
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
		dc
	end


	#  add a real visit
	def clinical_document(pat, visit, doc_type)
		cdoc = ClinicalDocument.new()
		cdoc.patient = pat.summary
		cdoc.visit = visit.summary
		cdoc.remote_id = 23
		cdoc.type_info = doc_type #.info #{type_id: doc_type.id, type_code: doc_type.code, class_id: doc_type.document_class[:id], class_code: doc_type.document_class[:code]}
		cdoc.save
		# dv = DocumentVersion.new
		# dv.clinical_document_id = cdoc.id
		# dv.version_number = 1
		# dv.save
		cdoc
	end


	def create_raw_name(entity)
		rn = RawName.new
		rn.raw_name = entity[:name].downcase
		rn.actual_name = entity[:name]
		rn.name_key = RawName.make_key(entity[:name])
		rn.entity = entity
		rn.status = 'active'
		rn.save
	end

	def add_user(uname, name)
		user = User.new
		user.user_name = uname
		user.full_name = name
		user.save
		user
	end

end
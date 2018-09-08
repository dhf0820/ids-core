require 'rest-client'
require 'base64'
require  '../sys_models/ids_error'
require './models/config'

class RemoteRepository

  def initialize
    @config = Config.active
    if @config.nil?
			raise IdsError.new(msg = "Customer Environment for #{ENV['CUSTOMER']} is not set up", 500)
    end
    
    #@header = {:content_type => 'application/json', :accept => 'json', :accept => 'application/vnd.chartarchive.v2'}
		@header = {:content_type=>"application/json",
			 :accept=>"application/vnd.chartarchive.v2",
			 :AUTHORIZATION=>"PizbvzxySn25uoFrvN9s"
      }

		@url = @config.remote_url
		if @url.nil?
			raise IdsError.new( 'Remote Repository is not configured', 500)
		end
		@token = @config.remote_token
		if @token.nil?
			raise IdsError.new( "Remote repository needs access information", 500)
		end

		@token = login('dhfrench@gmail.com')
		# get session if needed
		#RestClient.log = 'stderr'
	end

  def patient_by_mrn(mrn)
    puts "\n  @ Get Remote Patient for MRN: #{mrn}\n"
		url = "#{@url}/patients?mrn=#{mrn}"
		r = get(url)
		code = r[1]
    body = r[2]

		case code
		when 401
			#body = JSON.parse( ex.response.body)
			raise IdsError.new(body, code)
		when 404
			#body = JSON.parse( ex.response.body)
			return nil #raise IdsError.new(body, code)
		when 200
			return fill_pat(body)
		else
			raise IdsError.new(body, code)
		end
		# if r.nil?
		# 	raise IdsError.new("Patien mrn #{mrn} not found", 404)
		# end
		#fill_pat(body)
	end

  def patient_by_remote_id(id)
    puts "\n @ Find patient by remote_id: #{id}\n"
		url = "#{@url}/patients?id=#{id}"

		r = get(url)
		code = r[1]
		body = r[2]
		case code
			when 401
			    raise IdsError.new(body, code)
			when 404
				return nil
			when 200
				fill_pat(body)
			else
			    raise IdsError.new(body, code)
		end
	end

  def image_by_remote_id(id)
    puts "\n @ Find image by remote_id: #{id}\n"
		url = "#{@url}/archived_images/#{id}"

		r = get(url)
		code = r[1]
		body = r[2]
		#binding.pry
		case code
		when 401
			raise IdsError.new(body, code)
		when 404
			return nil
		when 200
			#binding.pry
			return body['image']
		else
			raise IdsError.new(body, code)
		end
	end

  def document_by_remote_id(id)
    puts "\n @ Find Document by remote_id: #{id}\n"
		url = "#{@url}/documents/#{id}"

		r = get(url)
		code = r[1]
		body = r[2]
		case code
		when 401
			#body = JSON.parse( ex.response.body)
			raise IdsError.new(body, code)
		when 404
			return nil
			#body = JSON.parse( ex.response.body)
			#raise IdsError.new(body, code)
		when 200
			d = body
		else
			raise IdsError.new(body, code)
		end

		c_doc = ClinicalDocument.new
		doc = d['document']
		c_doc.remote_id = doc['clinical_document_id']
		c_doc.doc_ref = doc['doc_ref']
		c_doc.image = doc['image'] #Base64.decode64(doc['image'])   # need to encrypt
		#binding.pry
		c_doc.patient = d['patient']
		c_doc.visit =d['visit']
		c_doc.type_info = d['document_type']

#todo  determine local IDs
		c_doc.save
		c_doc
	end

	def document_save(doc)
		#puts "Starting Document_save"
puts "\n @ Save to remote #{doc.id} ref: #{doc.doc_ref} date: #{doc.rept_date}\n"
		url = "#{@url}/documents"
		data = {}
		data[:patient] = doc.patient
		data[:doc_ref] = doc.doc_ref
		data[:rept_date] = doc.rept_date
		data[:recv_date] = doc.recv_date
		data[:facility] = doc.facility
		data[:sending_app] = 'ids'
		data[:document_type] = doc.type_info
		data[:img_flag] = 'ENCODED'
		#puts "Data being sent without image: #{data}"
		#binding.pry
		data[:enc_image] =  Base64.encode64(doc.image)  # decrypts image
		c_doc ={}
		c_doc[:document] =  data
		r = post(url, c_doc)
		#binding.pry
		code = r[1]
		body = r[2]
		case code
		when 401
			raise IdsError.new(body, code)
		when 404
			return nil
		when 201
			c_doc = body['document']
			doc.remote_id = c_doc['clinical_document_id']
			doc.description = c_doc['description']
			#doc.visit = c_doc['visit']
			#doc.type_info = c_doc['document_type']
			return doc
		else
			raise IdsError.new(body, code)
		end
	end

	# create a new remote patient based upon current one
	def patient_update(pat)
		puts "\n @ Remote patient_update: #{pat.inspect}\n"
		if pat.remote_id
			puts "Update remote have remote_id"
			update_patient(pat)  # patient exists and have reference to it
		else
			rpat = patient_by_mrn(pat.mrn)
			if rpat.nil?   # does not exist on remote
				puts "No MRN so create patient"
				p = create_patient(pat)   # create it
				#binding.pry
				pat = p
			else
				puts "Patient exists on remote save remote_id #{rpat['remote_id']}"
				pat.remote_id = rpat['remote_id']
				pat.save
				update_patient(pat)
				pat
			end
		end
		pat
	end


	def document_types
		url = "#{@url}/document_types"
		types = get(url)
		if types[0] = :success
			dts = types[2]
		else
			dts = nil
		end

		dts
	end

	def document_type(rem_id)
		url = "#{@url}/document_types/#{rem_id}"
		type = get(url)
		if type[0] = :success
			dt = type[2]
		else
			dt = nil
		end

		dt
	end


	def login(email)

		r = RestClient.get "https://chartarchive.herokuapp.com/api/v2/token?email=#{email}",
		                       {:content_type => 'application/json',
		                        :accept => 'application/vnd.chartarchive.v2+json'}

		JSON.parse(r.body)['token']

	end

	def create_patient(pat)
		puts "\n @ Create remote patient: #{pat.inspect}\n"
		url = "#{@url}/patients"
		data = {}
		#binding.pry
		data['patient'] = pat.attributes #JSON.parse(pat)
		data['patient']['ids_id'] = pat.id.to_s
		data['patient']['remote_id'] = pat.remote_id
		data['patient'].delete('_id')
		data['patient'].delete ('id')
		#data['patient'].delete('visits')
		data['patient'].delete('created')
		data['patient'].delete('updated')

		#data['patient'].delete('birth_date') if pat.birth_date.nil?

		r = post(url, data.to_json)
		#binding.pry
		code = r[1]
		body = r[2]
		case code
		when 401
			raise IdsError.new(body, code)
		when 404
			return nil
		when 201
			pat = fill_pat(body)
		else
			raise IdsError.new(body, code)
		end
		pat
	end

	private

  def update_patient(pat)
    puts "\n @ Update Remote patient: #{pat.remote_id}\n"
		url = "#{@url}/patients/#{pat.remote_id}"
		data = {}
		data['patient'] = pat.attributes # JSON.parse(pat.to_json)
		data['patient']['ids_id'] = pat.id.to_s
		data['patient']['remote_id'] = pat.remote_id
		data['patient'].delete('_id')
		data['patient'].delete ('id')
		data['patient'].delete('created')
		data['patient'].delete('updated')

		r = patch(url, data)

		code = r[1]
		body = r[2]
		#binding.pry
		case code
		when 401
			raise IdsError.new(body, code)
		when 404
			return nil
		when 200
			pat = fill_pat(body)
		else
			raise IdsError.new(body, code)
		end

		pat
	end

	def parse_json(data)
		JSON.parse(data)
	end

	def get(url)
		response = RestClient::Request.new({
			method: :get,
			url: url,
			headers: {
				:content_type=>"application/json",
				:accept=>"application/vnd.chartarchive.v2",
				:AUTHORIZATION=>"#{@token}"
			}
		}).execute do |response, request, result|
			case response.code
			when  400
				[:error, response.code, parse_json(response.to_str)]
			when 200
				[:success, response.code, parse_json(response.to_str)]
			when 404
				[:error, response.code, parse_json(response.to_str)]
			else
				[:error, response.code, parse_json(response.to_str)]
			end
		end
	end

	def post(url, data)

		response = RestClient::Request.new({
                       method: :post,
                       url: url,
                       payload: data,
                       headers: {
                           :content_type=>"application/json",
                           :accept=>"application/vnd.chartarchive.v2",
                           :AUTHORIZATION=>"#{@token}"
                       }
                   }).execute do |response, request, result|
			case response.code
			when  400
				[:error, response.code, parse_json(response.to_str)]
			when 201
				[:success, response.code, parse_json(response.to_str)]
			when 404
				[:error, response.code, parse_json(response.to_str)]
			else
				[:error, response.code, parse_json(response.to_str)]
			end
		end
	end

	def patch(url, data)
#binding.pry
		response = RestClient::Request.new({
	                   method: :patch,
	                   url: url,
	                   payload: data,
	                   headers: {
	                       :content_type=>"application/json",
	                       :accept=>"application/vnd.chartarchive.v2",
	                       :AUTHORIZATION=>"#{@token}"
	                   }
	               }).execute do |response, request, result|

			case response.code
			when  400
				[:error, response.code, parse_json(response.to_str)]
			when 201
				[:success, response.code, parse_json(response.to_str)]
			when 404
				[:error, response.code, parse_json(response.to_str)]
			else
				[:error, response.code, parse_json(response.to_str)]
			end
		end
	end

	def fill_pat(d)
		#puts "Fill pat: #{d}"
		pat = Patient.new
		pat.remote_id = d['remote_id']
		pat.mrn = d['mrn']
		pat.first_name = d['first_name']
		pat.middle_name = d['middle_name']
		pat.last_name = d['last_name']
		pat.name = d['name']
		pat.sex = d['sex']
		pat.marital_status = d['marital_status']
		begin
			pat.birth_date = Date.strptime(d['birth_date'],  '%Y-%m-%d')
		rescue
			pat.birth_date = nil
		end
		#pat.save
		pat
	end
end
require 'rest-client'
require 'base64'
require_relative  'ids_error'

class RemoteRepository

	def initialize
		#@header = {:content_type => 'application/json', :accept => 'json', :accept => 'application/vnd.chartarchive.v2'}
		@header = {:content_type=>"application/json",
			 :accept=>"application/vnd.chartarchive.v2",
			 :AUTHORIZATION=>"PizbvzxySn25uoFrvN9s"
			}
		if $cust_env.nil?
			raise IdsError.new(msg = "Customer Environment for #{ENV['CUSTOMER']} is not set up", 500)
		end
		@url = $cust_env.remote_url
		if @url.nil?
			raise IdsError.new( 'Remote Repository is not configured', 500)
		end
		@token = $cust_env.remote_token
		if @token.nil?
			raise IdsError.new( "Remote repository needs access information", 500)
		end

		@token = login('dhfrench@gmail.com')
		# get session if needed
		RestClient.log = 'stderr'
	end

	def patient_by_mrn(mrn)
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
			puts "When 200"
			fill_pat(body)
		when 500
			return nil
		else
			raise IdsError.new(body, code)
		end
		# if r.nil?
		# 	raise IdsError.new("Patien mrn #{mrn} not found", 404)
		# end
		#fill_pat(body)
	end

	def patient_by_remote_id(id)
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

	def document_by_remote_id(id)
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


		cd = ClinicalDocument.new
		cd.remote_id = d['clinical_document_id']
		# pat.mrn = d['mrn']
		# pat.first_name = d['first_name']
		# pat.middle_name = d['middle_name']
		# pat.last_name = d['last_name']
		# pat.name = d['name']
		# begin
		# 	pat.dob = Date.strptime(d['dob'],  '%Y-%m-%d')
		# rescue
		# 	pat.dob = nil
		# end
		# pat.save
		# pat
	end

	# create a new remote patient based upon current one
	def patient_update(pat)
		if pat.remote_id
			update_patient(pat)  # patient exists and have reference to it
		else
			rpat = patient_by_mrn(pat.mrn)
			if rpat.nil?   # does not exist on remote
				create_patient(pat)   # create it
			else
				pat.save
				update_patient(pat)
			end
		end
	end

	def login(email)

		r = RestClient.get "https://chartarchive.herokuapp.com/api/v2/token?email=#{email}",
		                       {:content_type => 'application/json',
		                        :accept => 'json',
		                        :accept => 'application/vnd.chartarchive.v2'}

		JSON.parse(r.body)['token']

	end


	private

	def update_patient(pat)
		if pat.remote_id.blank?  || pat.remote_id == '0'
			rpat = patient_by_mrn(pat.mrn)
			pat.remote_id = rpat.remote_id
			pat.save
		end
		# pat.birth_date = '' if pat.birth_date.nil?
		# pat.ssn = '' if pat.ssn.nil?
		# pat.marital_status = '' if pat.marital_status.nil?
		ph = pat.attributes
		ph.delete('_id')
		ph.delete('updated')
		ph.delete('created')
		url = "#{@url}/patients/#{pat.remote_id}"
		data = {}
		data['patient'] = JSON.parse(ph.to_json)
		data['patient']['ids_id'] = pat.id.to_s

		r = patch(url, data)

		code = r[1]
		body = r[2]

		case code
		when 401
			raise IdsError.new(body, code)
		when 404
			return nil
		when 200
			return fill_pat(body)
		else
			raise IdsError.new(body, code)
		end
	end

	def create_patient(pat)
		url = "#{@url}/patients"
		data = {}
		data['patient'] = JSON.parse(pat.to_json)
		data['patient']['ids_id'] = pat.id.to_s
		data['patient'].delete('_id')
		r = post(url, data)
		code = r[1]
		body = r[2]
		case code
		when 401
			raise IdsError.new(body, code)
		when 404
			return nil
		when 201
			fill_pat(body)
		else
			raise IdsError.new(body, code)
		end
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

		# r = RestClient::Request.execute({:method => :get,
		#                                  :url => url,
		#                                  :headers =>
		# 	                                 {:content_type=>"application/json",
		# 	                                  :accept=>"application/vnd.chartarchive.v2",
		# 	                                  :AUTHORIZATION=>"#{@token}"
		# 	                                 }
		#                                 })
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
		puts "response: #{response}"

		response
		# r = RestClient::Request.execute({:method => :post,
		#                                  :url => url,
		#                                  :payload => data,
		#                                  :headers =>
		# 	                                 {:content_type=>"application/json",
		# 	                                  :accept=>"application/vnd.chartarchive.v2",
		# 	                                  :AUTHORIZATION=>"#{@token}"
		# 	                                 }
		#                                 })
	end

	def patch(url, data)

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
			when 200
				[:success, response.code, parse_json(response.to_str)]
			when 404
				[:error, response.code, parse_json(response.to_str)]
			else
				[:error, response.code, parse_json(response.to_str)]
			end
		end

		puts "PATCH Response: #{response}"
		response
		#
		# r = RestClient::Request.execute({:method => :patch,
		#                                  :url => url,
		#                                  :payload => data,
		#                                  :headers =>
		# 	                                 {:content_type=>"application/json",
		# 	                                  :accept=>"application/vnd.chartarchive.v2",
		# 	                                  :AUTHORIZATION=>"#{@token}"
		# 	                                 }
		#                                 })
	end

	def fill_pat(d)
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
		pat.save
		pat
	end
end
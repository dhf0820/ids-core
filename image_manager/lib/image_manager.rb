

puts "Starting ImageManager"
#require 'active_record'
require 'mongoid'
#require 'rest-client'
require 'json'
require 'pry-coolline'
require 'find'
require 'colorize'
require 'yaml'
require 'bunny'

# Base system model/libs requires
require '../sys_models/patient.rb'
require '../sys_models/clinical_document.rb'
require '../sys_models/app_environment'
require '../sys_models/customer_environment'
require '../sys_models/remote_repository'
require '../sys_models/archived_image.rb'
require '../sys_models/visit.rb'
require '../sys_models/document_type.rb'
require "../sys_lib/vs_log"
require '../sys_lib/work_queue'

require './models/unknown_document.rb'
require './models/failed_document.rb'
require './models/chart_archive_delivery'

require './lib/image_manager'
require './lib/save_failure.rb'
require './lib/version'
require './lib/save_failure.rb'

class ImageManager

	def initialize()
		puts "\n\nInitializing ImageManager Version #{VERSION}"
    start_time = Time.now
    @config = Config.new
    puts "   Config elapsed time: #{(Time.now - start_time) * 1000.0}ms"
    @cac = ChartArchiveClass.default
    #puts "   ChartArchiveClass elapsed time: #{Time.now - start_time}ms"
    @cad = ChartArchiveClass.default_device
    #puts "   ChartArchiveDelivery elapsed time: #{Time.now - start_time}ms"

    puts "ImageManager initialize elaposed time: #{(Time.now - start_time) * 1000.0}ms\n\n"
	end

	def execute
		process_queue
	end

	def process_queue()
		# Signal.trap("TERM") do
		# 	$log.warn "Terminating..."
		# 	ActiveRecord::Base.connection_pool.release_connection
		# 	@connection.close
		# end

		begin
			$log.info "\n           Starting ImageManager\n"
			$log.info("[x]  ImageManager version #{VERSION} waiting for job on #{@archive_queue.queue.name}")
			#puts "[x]  Waiting for job on #{@archive_queue.queue.name}"
			@archive_queue.queue.subscribe(:manual_ack => true,:block => true) do |delivery_info, properties, body|
        $qd =  HashWithIndifferentAccess.new(JSON.parse(body))
        #@qd = JSON.parse(body)
				$log.debug( "   Image_type: #{@qd['image_type']}")
				$log.info(  "   Report_type: [#{@qd['report_type']}]")
				$log.debug( "   ReceivedDate: #{@qd['received_date']}")
        start_time = Time.now

				qd = process_job(@qd)
				# if @qd['image']
				# 	image = Base64.decode64(@qd['image'])
				# else
				# 	puts "   Processing File: #{@qd['file_name']}"
				# 	image = File.open(@qd['file_name']).read
				# end
				if qd == 'Restarted'
					$log.warn "\nJob: #{}"
				elsif qd == 'Ok'
					$log.info "\nImageManager job #{@qd['job_id']} took #{(Time.now - start_time).in_milliseconds}ms\n"
					@archive_queue.ack(delivery_info.delivery_tag)
					$log.debug("[x]  ImageManager version #{VERSION} waiting for job on #{@archive_queue.queue.name}")
				end

			end
		rescue Interrupt => ex
			@archive_queue.ch.close
      @connection.close
      exit(0)
    rescue Exception => ex
      @archive_queue.ch.close
			@connection.close
      $log.fatal "   ProcessQueue exception #{ex.inspect}"
      exit(0)
		end
	end


	def process_job(qd)
		if qd['status'] == 'unknown'
			process_unknown(qd)
		else
			begin
				#$log.debug "processing job"
				@current_image = Base64.decode64(qd['image'])
				qd.delete('image')
				pat = process_patient(qd)
				#$log.debug "Processed Patient: #{pat.name}"
				#@qd['patid'] = pat.id.to_s
				qd['pat_remote'] = pat.remote_id
				qd['pat_summary'] =  pat.summary
				visit = process_visit(qd, pat)
				#$log.debug "Process Visit : #{visit.id.to_s}"
				#qd['visit_id'] = visit.id.to_s
				qd['visit_summary'] = visit.summary
				#$log.debug "Adding a document"
				qd = add_document(qd, @current_image, pat, visit)
				return qd if qd == 'Restart'
        queue_to_chart_archive(qd)
				queue_dispatch(qd)
				#$log.info "Queued to Dispatch Patient: [#{pat.id.to_s}] - [#{pat.name}], ClinicalDocumentId: [#{qd['doc_id']}] [#{qd['type_info']['description']}]"
			rescue SaveFailure => e
				qd['ERROR']=  e.message
				queue_failure(e.message)
			end
		end
		qd
	#	binding.pry

	end

	# TODO set the facility this is for
	def process_unknown(qd)
		begin
			$log.warn "Processing unknown job: #{qd['job_id']}"
			ud = UnknownDocument.new
			image = qd['image']
			qd['image'] = nil
			ud.data = qd
			ud.source = qd['source']
			ud.job_id = qd['job_id']
			ud.received_date = qd['received_date']
			ud.image = image
			ud.save!
		rescue Exception => e
			$log.warn "Save unknown failed: #{e}"
		end

	end

	def process_patient(qd)
		pat_name = qd['pat_name']
		medrec = qd['mrn']
		# $log.debug "   Patient Name: #{pat_name}"
		# $log.debug "   MRN: #{medrec}"

		if medrec.blank?
			raise SaveFailure, "   !mrn is blank"
		end
		pat = Patient.by_mrn(medrec)
		if pat.blank?
			pat = add_patient(qd)
		end
		pat
	end


	def process_visit(qd, pat)
		if qd['visit_num'].blank?

			visit = pat.default_visit
		else
			visit = pat.visit(qd['visit_num'])
		end
		visit
	end

	def add_patient(qd)

		#$log.debug "Add patient"
		pat = Patient.new
		pat.mrn = qd['mrn']
		pat.name = qd['pat_name']

		pat.split_name

		begin
		#	$log.debug "Saving patient #{pat.inspect}"
			#binding.pry
			pat.save  # save__with_remote
		#	$log.debug "   Saved successfully"
		rescue ActiveRecord::RecordNotUnique => e
			pat = Patient.by_mrn(pat.mrn).first
			if pat.blank?
				$log.warn "Patient MRN: [#{pat.mrn}]  Name: [#{pat_name}] save failed Detail: [#{e.inspect}]"
				raise SaveFailure, "Patient mrn: #{pat.mrn}  name: #{pat_name} save failed: #{e.inspect}"
			end
		rescue	Exception => e
			$log.warn "Patient MRN: [#{pat.mrn}]  Name: [#{pat.name}] save failed Detail: [#{e.inspect}]"
			raise SaveFailure, "Patient mrn: #{pat.mrn}  name: #{pat.name} save failed: #{e.inspect}"
		end
		#$log.debug "Patient: #{pat.inspect}"
		pat
	end


	def add_document (qd, image, pat, visit = nil)
	#	$log.debug "add_document for patient: #{pat.name}"
		# TODO if there is a doc_ref check for existing document and add as version. Return the existing version
		# otherwise it is a new document if doc_ref not found or not given
		c_doc = nil
		qd['patient'] = pat.summary
		qd['visit'] = visit.summary unless visit.nil?
		dt = DocumentType.by_code(qd['report_type'])
		if dt.blank?
			raise SaveFailure, "invalid document_type #{qd['report_type']}"
		end
		qd['type_info'] = dt.summary
		#@qd['class_id'] = dt.class_id
		# if qd['doc_ref']
		# 	c = ClinicalDocument.for_patient_doc_type_ref(pat.id, dt.id, qd['doc_ref'])
		# end
		# if c.nil?   # document does not exist already
			c_doc = ClinicalDocument.new
			c_doc.visit = visit.summary
			c_doc.patient = pat.summary
			c_doc.type_info = dt.summary
			c_doc.doc_ref = qd['doc_ref']
			c_doc.pages = qd['pages']
			c_doc.image = image
			begin
				c_doc.save
		#		$log.info "Document [#{c_doc.id.to_s} #{dt.description}  saved"
			rescue Exception => e
				#initialize_rabbit
				# binding.pry
				# $log.warn "\n\nsave clinical document error: #{e.inspect}"
				# $log.warn "Add ClinicalDocument failed #{e.message} for document_type: #{qd['report_type']}"
				# raise SaveFailure "Clinical Document save failed: #{e.message}"
				return 'Restart'
			end
			qd['doc_id'] = c_doc.id.to_s
			qd['doc_remote_id'] = c_doc.remote_id
		qd
	end

	# def add_version(doc, pat, doc_type)
	# 	next_number = DocumentVersion.next_version_for_patient_doc_type_ref(pat.id, doc.type_id, @qd['doc_ref'])
	# 	#num_versions = DocumentVersion.where("clinical_document_id = doc.id").order("version_number: :desc")
	# 	dv = DocumentVersion.new
	# 	dv.clinical_document_id= doc.id
	# 	dv.version_number = next_number
	# 	dv.sending_app = @qd['source']
	# 	dv.document_type_id = doc.type_id
	# 	dv.description = doc_type.description
	# 	dv.pages = @qd['pages']
	# 	dv.recv_datetime = Time.parse(@qd['received_date']) unless @qd['received_date']
	# 	#dv.pages = 3
	# 	unless @qd['transcribed_date']
	# 		begin
	# 			dv.trans_datetime = Time.strptime(@qd['transcribed_date'], "%m/%d/%Y %H:%M %p")
	# 		rescue
	# 			$log.warn "!!! Transcribed date #{@qd['transcribed_date']} is invalid"
	# 		end
	# 	end
	# 	unless @qd['recv_date']
	# 		begin
	# 			dv.recv_datetime = Time.strptime(@qd['rept_date'], "%m/%d/%Y %H:%M %p")
	# 		rescue
	# 			dv.recv_datetime = Time.now
	# 		end
	# 	else
	# 		dv.recv_datetime = Time.now
	# 	end
	#
	# 	unless @qd['rept_date']
	# 		begin
	# 			dv.rept_datetime = Time.strptime(@qd['rept_date'], "%m/%d/%Y %H:%M %p")
	# 		rescue
	# 			$log.debug "    Rept Date = [#{@qd['rept_date']}"
	# 			$log.warn "!!! Report date #{@qd['rept_date']} is invalid"
	# 		end
	# 	end
	#
	# 	unless @qd['edit_date']
	# 		begin
	# 			dv.edit_datetime = Time.strptime(@qd['edit_date'], "%m/%d/%Y %H:%M %p")
	# 		rescue
	# 			$log.warn "!!! Edit date #{@qd['edit_date']} is invalid"
	# 		end
	# 	end
	# 	img = @qd['image']  # save if failure
	# 	# now it is safe to remove the image from the json and add the image_id
	# 	# need to update the rep_header in Archive
	# 	@qd['image'] = nil
	# 	begin
	# 		ai = dv.new_image(pat.mrn, @qd.to_s, Base64.decode64(img))
	# 	rescue Exception => e
	# 		$log.warn "Image Save failed: #{e.message}"
	# 		raise SaveFailure, "Image Save failed: #{e.message}"
	# 	end
	#
	# 	begin
	# 		dv.save!
	# 	rescue Exception => e
	# 		$log.warn "DocumentVersion failed to save: #{e.message}"
	# 		raise SaveFailure "DocumentVersion failed to save: #{e.message}"
	# 	end
	#
	# 	# now it is safe to remove the image from the json and add the image_id
	# 	# need to update the rep_header in Archive
	# 	@qd['image'] = nil
	# 	dv
	# end


# 	def split_name(pat)
#
# 		if pat.name.blank?
# 			$log.warn "Patient name is blank"
# 			raise SaveFailure "Patient name is blank"
# 		end
# #TODO Check if name contains a comma if does not it is first last
# 		names = pat.name.split(',')
# 		if names.count > 1      # comma lastname first
# 			pat.last_name = names[0].strip
# 			pat.first_name = names[1].strip
# 			if names.count > 2
# 				pat.middle_name = names[2].strip
# 			end
# 		else
# 			names = pat.name.split(' ')
#
# 			if names.count < 3
# 				pat.first_name = names[0]
# 				pat.last_name = names[1]
# 			else
# 				pat.first_name = names[0]
# 				pat.middle_name = names[1]
# 				pat.last_name = names[2]
# 			end
# 		end
#
# 		pat
# 	end

	#queue the current job to the failuer work queue
	def queue_failure(msg)

		$log.warn "Queue the failure [#{msg}] to the failure queue"
		#begin
			$log.warn "Processing unknown job: #{@qd['job_id']}"
			fd = FailedDocument.new
			fd.data = @qd
			fd.source = @qd['source']
			fd.job_id = @qd['job_id']
			fd.received_date = @qd['received_date']
			fd.image = @current_image
			fd.failed_reason = msg
			fd.save!
		#rescue Exception => e
			#$log.warn "Save FailedDocument failed: #{e}"
		#end

	end

  def queue_to_chart_archive(qd)
    # either here or in dxelivery_manager
    #binding.pry
  end

	def queue_dispatch(qd)
		@config.out_queue.publish(qd)
	#	$log.debug "Queue the dispatch to determine delivery"
	end


end



#require 'rest-client'
require 'json'
require 'pry-coolline'
require 'find'
require 'colorize'
require 'yaml'
require 'bunny'

#require '../sys_lib/mongo_connection'
require './models/config'

# require './models/patient.rb'
# require './models/clinical_document.rb'
# require './models/document_version.rb'
# require './models/archived_image.rb'
# require './models/visit.rb'
# require './models/document_type.rb'
require '../sys_models/raw_name.rb'

require '../sys_models/physician.rb'
require '../sys_models/practice'
require '../sys_models/delivery_request.rb'
require '../sys_models/pending_delivery'
require '../sys_models/app_environment'
require '../sys_models/customer_environment'
require '../sys_models/delivery_device.rb'
require '../sys_models/delivery_class.rb'
#require './models/delivery_job.rb'
require '../sys_models/environment'
#
require '../sys_lib/vs_log'
#require './lib/in_queue.rb'
# require './lib/deliver_queue.rb'
# require './lib/dispatch_failure.rb'
require "../sys_lib/work_queue.rb"

require './lib/version'
require '../sys_models/ids_error'

class DeliveryManager

  def initialize()
   
    @config = Config.active

    @in_queue = @config.in_queue

		@queued = {}
		@entities = {}
		@no_deliveries = {}
	end

	def run
		process_queue
	end

	def process_queue()
		$log.info "     IDS-DeliveryManager is starting"
		begin
			$log.info "[x]  DeliveryManager version #{VERSION} waiting for job on #{@in_queue.queue.name}"
			@in_queue.queue.subscribe(:manual_ack => true,:block => true) do |delivery_info, properties, body|
				@qd = JSON.parse(body)
				#$log.debug "Image_type: #{@qd['image_type']}"
				#$log.debug "Report_type: #{@qd['report_type']}"
				#$log.debug "ReceivedDate: #{@qd['received_date']}"
				start_time = Time.now
				process_job(@qd)
				$log.debug "\nTime to manage: #{(Time.now - start_time).in_milliseconds}ms\n"
				@in_queue.ack(delivery_info.delivery_tag)
				$log.debug "Finished Job #{@qd['jpb_id']} -  #{@qd['pat_name']} - #{@qd['mrn']}"
				$log.debug "[x]  DeliveryManager version #{VERSION} Waiting for job on #{@in_queue.queue.name}"
			end
		rescue Interrupt => ex
			@in_queue.ch.close
			@config.amqp_connection.close
		rescue Exception => ex
			$log.warn "   ProcessQueue exception #{ex.inspect}"
		end
	end


	def process_job(data)
		# There will only be generating and cc types entities. will continue to pickup by type
		# though profile specifies generating or cc only  all except generating will be delivered base upon cc


		@data = data
		@doc_id = data['doc_id']
		@doc = ClinicalDocument.find(@doc_id)
		@queued = {}
		@entities = {}
    @no_deliveries = {}
    queue_chart_archive(@doc)
		begin
			primary_physicians = %w(ordering_physician consulting_physician referring_physician pcp)

			process_entity(@doc, data['generating'], :generating) if @data['generating']

			primary_physicians.each do |p|
				process_entity(@doc, @data[p], :specified) if @data[p]
			end

			process_entity(@doc, @data[:pcp], :pcp) if @data[p]

			(1..5).each do |i|
				process_entity(@doc, @data["cc#{i}"], :cc) if @data["cc#{i}"]
			end

			(1..5).each do |i|
				process_entity(@doc, @data["phy-#{i}"], :cc) if @data["phy-#{i}"]
			end
		rescue DispatchFailure => e
			#puts "DispatchFailure:  #{e.message}"
			$log.warn "DispatchFailure:  #{e.message}"
		end
		#puts "Finished Job #{data}"
		# $log.info "Finished Job #{data}"
	end


	def process_entity( doc, name, context)
		# name = @data[key]
		# doc_id = @qd['doc_id']
		#$log.debug "Processing Physician: [#{key}] = [#{name}]"

		unless name.blank?
			begin
				raw = RawName.lookup(name)


				#$log.debug "raw.status: #{raw.status}  -  lookup: #{raw.inspect}"
				if raw.status == 'new'   # waiting to be linked add to PendingDelivery
					queue_pending(raw, doc)
					# pd = PendingDelivery.new
					# pd.phy_name = name
					# pd.doc_id = @qd['doc_id']
					# pd.raw_name_id = rn.id
					# pd.save
					# add_delivery( rn.id, name )
				else
					queue_delivery(raw, doc, context)
				end

			rescue Exception => e
				# TODO If queue fails on this physician, save the physician info and doc info in dispatch error
				puts "Process_physician exception: #{e}"
				#$log.warn "Process_physician exception: #{e}"
			end
		end
	end

	def queue_delivery(raw, doc, context)
		class_dps = DeliveryProfile.by_doc_class(doc.type_info, raw.entity) #, [context])
		type_dps = DeliveryProfile.by_doc_type(doc.type_info, raw.entity) #, [context])
    entity = raw.entity

		if(class_dps.count == 0)
			if type_dps.count == 0
	#if entity has a primary device check if this document has been delivered to it
	# if no primary device, check if mail has been delivered for this document to the entity.
				if entity['primary_device']
          unless already_queued?(entity['primary_device'], entity, doc)
            puts "Queue DEfault 1: #{entity}"
						DeliveryRequest.queue_default(entity, doc)
					end
				else
          unless already_queued_to_default?(entity, doc)
            puts "Queue Default 2: #{entity}"
						DeliveryRequest.queue_default(entity, doc)
					end
				end

				return
			else
				puts "Begin delivering real document_type profile\n"
				deliver_profile(type_dps, doc, raw.entity, context)    #DeliveryProfile.by_doc_type(doc.type_info, raw.entity, [context]),  doc, raw.entity)
				return
			end
		else
			puts "Begin delivering real document class profile\n"
			deliver_profile(class_dps, doc, raw.entity, context)  #DeliveryProfile.by_doc_class(doc.type_info, raw.entity, [context]),  doc, raw.entity)

		end

		#deliver_profile(class_dps, doc, raw.entity, context)  #DeliveryProfile.by_doc_class(doc.type_info, raw.entity, [context]),  doc, raw.entity)
		#deliver_profile(type_dps, doc, raw.entity, context)    #DeliveryProfile.by_doc_type(doc.type_info, raw.entity, [context]),  doc, raw.entity)
	end


	def deliver_profile(dps, doc, entity, context)
		#puts "Deliver Profile dps: #{dps.count}\n"
		dps.each do|dp|
			return unless dp.delivery_context.include?(context.to_sym)
			unless already_queued?(dp.device, entity, doc)
				DeliveryRequest.request_delivery(dp, doc)
				add_delivery(dp, doc, entity)
			end
		end
	end

	def queue_pending(raw, doc)
		#$log.debug "\nCheck if pending has been already queued for #{raw.raw_name}"
		#return if already_queued?(raw.id)
		#$log.debug "Queue Pending delivery for #{raw.raw_name}"
		pd = PendingDelivery.by_raw_doc(raw.id, doc.id)

		if pd.nil?
			puts "Add PendingDelivery of doc #{doc.id} for unlinked name #{raw.raw_name}"
			pd = PendingDelivery.new
			pd.name = raw.raw_name
			pd.clin_doc_id = doc.id
			pd.raw_name_id = raw.id
			pd.save
		else
			puts "PendingDelivery to #{raw.raw_name} for document #{doc.id} is already queued"
		end
		pd
	end

	# Check if document has already been queued to the profile device
	def already_queued?(device, entity, doc)
		queued = DeliveryRequest.where(document: doc.summary, recipient: entity, device: device).count > 0
		queued
	end

	def already_queued_to_default?(entity, doc)
		device = MailDeliveryClass.default_device
		queued = DeliveryRequest.where(document: doc.summary, recipient: entity, device: device.summary).count > 0
		queued
	end
	# Document has been delivered to the  profile device and entity
	# all we care is that
	def add_delivery(dp, doc, entity)
		@queued[dp.device[:id].to_s] = doc.id
		@entities[entity[:id]] = doc.id
	end

	def no_delivery(entity, doc)
		@no_deliveries["#{entity[:context]}-#{entity[:id]}"] = doc.id
	end

	def undelivered
		@no_deliveries
	end

  def queue_chart_archive(doc)
    cad = @config.chart_archive_device
    entity = {}
    entity[:ids_id] = nil?
    entity[:name] = 'ChartArchive'
    entity[:context] = "remote"
    entity[:primary_device] = cad.summary
    cad.queue(doc, entity)
  end

end
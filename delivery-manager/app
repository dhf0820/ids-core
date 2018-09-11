#!/usr/bin/env ruby

#ENV['MONGO_ENV']= 'development'

require '../sys_lib/mongo_connection'
require '../sys_models/patient.rb'
require '../sys_models/updateable'
require '../sys_models/clinical_document.rb'
#require '../sys_models/document_version.rb'
#require './models/archived_image.rb'
require '../sys_models/visit.rb'
require '../sys_models/document_type.rb'
require '../sys_models/raw_name.rb'
require '../sys_models/pending_delivery.rb'
require '../sys_models/physician.rb'
require '../sys_models/delivery_request.rb'
require '../sys_models/delivery_device.rb'
require '../sys_models/delivery_class.rb'
#require './models/delivery_job.rb'
require '../sys_models/environment'
require '../sys_models/ids_error'
require '../sys_lib/vs_log'
#require './lib/dispatch_queue.rb'
#require './lib/deliver_queue.rb'
require "../sys_sys_lib/work_queue.rb"
#require "../lib/in_queue"

require './lib/version'
require './models/delivery_manager'
require './lib/dispatch_failure.rb'


STDERR.puts "Starting version #{VERSION} Dispatcher"
#puts "Arguments: #{ARGV}"
@config = Config.new
dm = DeliveryManager.new()

dm.run
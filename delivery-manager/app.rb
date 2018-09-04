#!/usr/bin/env ruby

#ENV['MONGO_ENV']= 'development'


require './lib/mongo_connection'
require './models/patient.rb'
require './models/updateable'
require './models/clinical_document.rb'
require './models/document_version.rb'
#require './models/archived_image.rb'
require './models/visit.rb'
require './models/document_type.rb'
require './models/raw_name.rb'
require './models/pending_delivery.rb'
require './models/physician.rb'
require './models/delivery_request.rb'
require './models/delivery_device.rb'
require './models/delivery_class.rb'
#require './models/delivery_job.rb'
require './models/environment'
require './models/ids_error'

require './lib/vs_log'
require './lib/dispatch_queue.rb'
require './lib/deliver_queue.rb'
require './lib/dispatch_failure.rb'
require "./lib/work_queue.rb"

require './lib/version'
require './models/delivery_manager'



STDERR.puts "Starting version #{VERSION} Dispatcher"
#puts "Arguments: #{ARGV}"
dm = DeliveryManager.new()

dm.run
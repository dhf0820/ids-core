#!/usr/bin/env ruby

require './lib/version'

puts "ImageManager version #{VERSION} starting "
require '../sys_lib/mongo_connection'

require 'active_record'
require 'mongoid'
#require 'rest-client'
require 'json'
require 'find'
require 'colorize'
require 'yaml'
require 'bunny'

require 'pry-coolline'

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
require '../sys_models/chart_archive_delivery'

require './lib/image_manager'
require './lib/save_failure.rb'
require './lib/version'
require './lib/save_failure.rb'
#include EfaxProcessor
#require './lib/image_manager.rb'


#extractor = Extractor::Extractor.new
Config.new
img_manager = ImageManager.new
puts "ImageManager: #{image_manager.inspect}"
img_manager.execute
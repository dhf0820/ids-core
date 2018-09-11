#!/usr/bin/env ruby
require 'optparse'
require 'pry'
require 'mongoid'
require 'bunny'
require 'yaml'

require '../sys_lib/mongo_connection'
require '../sys_lib/work_queue'
require '../sys_lib/vs_log'
require '../sys_models/environment'

require './models/config'
require './models/data_dictionary'
require './models/data_element'
require './models/data_elements'
require './models/data_field'
require './models/descriptor'
require './models/document'
require './models/document_def'
require './models/exceptions'
require './models/page'
require './models/processor'
require './models/queue_processor'
require './models/recognizer'
require './models/recognizers'
require './models/report'
#require './models/unknown_queue'


require './lib/ids-reader'
require './lib/pdf2_text'
require './lib/string_ext'



#puts "in Reader executable "

require './lib/cli'

#$path = File.expand_path(File.dirname(__FILE__))
#$service = File.basename($0)



#extractor = Extractor::Extractor.new
CLI.execute
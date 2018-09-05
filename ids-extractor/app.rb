#!/usr/bin/env ruby
require 'optparse'
require 'pry'
require 'mongoid'
require 'bunny'
require 'yaml'

require_relative './lib/mongo_connection'
require_relative './models/config'
require_relative './models/data_dictionary'
require_relative './models/data_element'
require_relative './models/data_elements'
require_relative './models/data_field'
require_relative './models/descriptor'
require_relative './models/document'
require_relative './models/document_def'
require_relative './models/environment'
require_relative './models/exceptions'
require_relative './models/inbound_queue'
require_relative './models/page'
require_relative './models/processor'
require_relative './models/queue_processor'
require_relative './models/recognizer'
require_relative './models/recognizers'
require_relative './models/report'
require_relative './models/next_queue'
require_relative './models/unknown_queue'


require_relative './lib/ids-reader'
require_relative './lib/pdf2_text'
require_relative './lib/string_ext'
require_relative './lib/vs_log'


#puts "in Reader executable "

require_relative './lib/cli'

#$path = File.expand_path(File.dirname(__FILE__))
#$service = File.basename($0)



#extractor = Extractor::Extractor.new
CLI.execute
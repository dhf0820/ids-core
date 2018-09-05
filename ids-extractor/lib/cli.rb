require 'optparse'
require 'pry'
require 'mongoid'
require 'bunny'
require 'yaml'

require_relative '../models/config'
require_relative '../models/app_environment'
require_relative '../models/customer_environment'
require_relative '../models/data_dictionary'
require_relative '../models/data_element'
require_relative '../models/data_elements'
require_relative '../models/descriptor'
require_relative '../models/document_def'

require_relative '../models/ids_error'
require_relative '../models/inbound_queue'
require_relative '../models/next_queue'
require_relative '../models/page'
require_relative '../models/processor'
require_relative '../models/queue_processor'
require_relative '../models/recognizer'
require_relative '../models/recognizers'
require_relative '../models/report'
require_relative '../models/unknown_queue'
require_relative '../models/updateable'


require_relative './ids-reader'
require_relative './pdf2_text.rb'
require_relative './version'
require_relative './string_ext'
require_relative './vs_log'



require_relative './mongo_connection'

#module IDSReader
	class CLI


		def initialize_queues(connection)

		end

		def self.execute()

			options = {
				type:  nil,
				debug: :WARN,
				environment: nil,
				reader: nil,
				mode: 'test'
			}
			#unless $rspec_test
			#
			# 	mandatory_options =  %w(reader)  # Required options that must be present or will not start
			#
			# 	@parser = OptionParser.new do |opts|
			# 		opts.banner = <<-BANNER.gsub(/^          /,'')
	         #  This application is wonderful because... it is
			#
	         #  Usage: #{File.basename($0)} [options]
			#
	         #  Options are:
			# 		BANNER
			# 		opts.separator ""
			# 		# opts.on('-c', '--config YAML_FILE', String,
			# 		#         'Specifies the YAML file that defines the defaults for this reader.',
			# 		#         'Other options provided on command line over-ride those in yaml file.',
			# 		#         'Must be first if given.',
			# 		#         'Default: READER_NAME',
			# 		#         ' ') {|arg| options[:config] = arg}
			# 		opts.on("-d","--debug LEVEL", String,
			# 		        "The level of loging detail.",
			# 		        "FATAL",
			# 		        "ERROR",
			# 		        "WARN",
			# 		        "INFO",
			# 		        "DEBUG",
			# 		        "DEBUG1-9",
			# 		        "If not used will use the value defined in the System.yml config file",
			# 		        " "
			# 		) {|arg| options[:debug] = arg}
			# 		opts.on('-h', '--help',
			# 		        'Show this help message.',
			# 		        ' ') { puts opts; exit }
			#
			# 		opts.on("-r", "--reader NAME", String,
			# 		        "REQUIRED Name of reader configuration to run."
			# 		        #"If given overrides the default of program name. "
			# 		) { |arg| options[:reader] = arg}
			# 		opts.on('-m', '--mode TEST|LIVE', String,
			# 		        'Runtime mode. Default is test.',
			# 		        ' '
			# 		) { |arg| options[:mode] = arg}
			# 		begin
			# 			opts.parse!(ARGV)
			# 		rescue OptionParser::InvalidOption
			# 			puts "Invalid option #{$rspec_test} - #{ARGV}"
			# 			puts opts; exit
			# 		end
			#
			# 		# if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
			# 		# 	#binding.pry
			# 		# 	puts opts; exit
			# 		# end
			#
			#
			# 	end
			# end

			#db = ENV['DATABASE_URL']

			STDERR.puts "Starting Version #{VERSION} of Reader"

			service = ENV['SERVICE']

			if service.nil?
				service = 'reader'
				ENV['SERVICE'] = 'reader'
			end
			customer = ENV['CUSTOMER']



			if customer.nil?
				STDERR.puts "Customer is nil using default of 'ids'"
				customer = 'ids'
			end
			STDERR.puts "   Customer: #{customer}  -  service: #{service}"

			#puts "Requested reader: [#{options[:reader]}]"
			#puts "options: #{options}"


			$configuration = Config.new(customer, service)

			$reader = Reader.new($configuration)

			inqueue = QueueProcessor.new( $reader)

			inqueue.process_queue

		end


	end


#end
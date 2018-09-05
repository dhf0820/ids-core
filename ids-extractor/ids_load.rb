#!/usr/bin/env ruby

require 'mongoid'
require './lib/mongo_connection'  # here because it makes the mongo connection also
require './models/document_def'
require './models/data_dictionary'
require './models/document_type'
require './models/data_elements'
require './models/data_element'
require './models/descriptor'
require './models/environment'
require './models/app_environment'
require './models/customer_environment'
require './models/remote_repository'

require './models/config'
require './lib/vs_log'

require 'pry'

service = ENV['SERVICE']

customer = ENV['CUSTOMER']

STDERR.puts "   Customer: #{customer}  -  service: #{service}"



$configuration = Config.new(customer, service)

$remote = RemoteRepository.new

def create_data_dictionary
	t = DataDictionary.new
	t.name = 'pat_name'
	t.length = 30
	t.element_type = :alphanumeric
	t.save

	t = DataDictionary.new
	t.name = 'acct_num'
	t.length = 12
	t.element_type = :numeric
	t.save

	t = DataDictionary.new
	t.name = 'mrn'
	t.length = 8
	t.element_type = :numeric
	t.save

	t = DataDictionary.new
	t.name = 'pcp'
	t.length = 30
	t.element_type = :alphanumeric
	t.save

	t = DataDictionary.new
	t.name = 'cc1'
	t.length = 30
	t.element_type = :alphanumeric
	t.save

	t = DataDictionary.new
	t.name = 'cc2'
	t.length = 30
	t.element_type = :alphanumeric
	t.save

	t = DataDictionary.new
	t.name = 'dob'
	t.length = 10
	t.element_type = :date
	t.save

	t = DataDictionary.new
	t.name = 'rept_date'
	t.length = 10
	t.element_type = :date
	t.save

	t = DataDictionary.new
	t.name = 'ssn'
	t.length = 30
	t.element_type = :alphanumeric
	t.picture = '/\d{3}-?\d{2}-?\d{4}/'
	t.save

end

num = DocumentDef.count
puts "Number of definitions: #{num}"

if ARGV.empty?
	puts "command: manage_recognizers add|remove|list  (name) (file_name)  "
	exit 1
end


case ARGV[0]
	when 'list'
		recogs = DocumentDef.all
		if recogs.count == 0
			puts "No Document Recognizers defined"
		else
			recogs.each do |r|
				puts "Name: #{r.name}  type: #{r.document_type}"
			end
		end
when 'add'
	doc_type = ARGV[1]
	file_name = ARGV[2]
	name = file_name.split( '/')[-1].split('.')[0]
	ml = DocumentDef.by_name(name)
	ml = DocumentDef.new if ml.nil?
	ml.definition = File.open(file_name, "r").read
	ml.name = name
	ml.document_type = doc_type
	#puts "Reader: #{ml.inspect}"
	puts "Adding recognizer #{name} as document_type: #{doc_type}"
	ml.save
when 'remove'
	name = ARGV[1]
	ml = DocumentDef.by_name(name)
	if ml
		puts "Removing  Recognizer: #{name} be sure it is removed from all readers"
		ml.delete
	else
		puts "Recognizer #{name} does not exist"
	end
when 'fields'
	create_data_dictionary
when 'types'
	puts "Loading Document types and classes. Please wait"
	DocumentType.load_types
else
	puts "Invalid command: #{ARGV[0]}. Options are list, add, remove"
end




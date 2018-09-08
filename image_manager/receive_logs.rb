#!/usr/bin/env ruby
# encoding: utf-8
require 'active_record'
require 'pg'
require './lib/db_connection'
require "./models/environment"
require "bunny"

# if ARGV.empty?
# 	abort "Usage: #{$1} [binding key]"
# end
db_connection = DbConnection.new
ids = Environment.for_process('ids')
if ids.nil?
	abort("ids environment is not set up\n")
end
ids_amqp = ids.env 'AMQP'

ActiveRecord::Base.remove_connection

puts "Listening on #{ids_amqp}"
conn = Bunny.new(ids_amqp)
#conn = Bunny.new(:automatically_recover => false)
conn.start

ch  = conn.create_channel
x   = ch.topic("ids_logs")
q   = ch.queue('', :exclusive => true)

ARGV.each do |severity|
	puts "Listining for keys: #{severity}"
	q.bind(x, :routing_key => severity)
end

if ARGV.count == 0
	q.bind(x, :routing_key => "#")
	puts "Listining for keys: #"
end

puts " [*] #{Time.now.strftime("%m/%d/%Y-%H:%M:%S")} - Waiting for logs. To exit press CTRL+C"

begin
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts " #{Time.now.strftime("%m/%d/%Y-%H:%M:%S")} - #{delivery_info.routing_key}:#{body}"
	end
rescue Interrupt => _
	ch.close
	conn.close

	exit(0)
end
require './models/updateable'
require './models/ids_error'


class Environment
	require 'json'
	include Mongoid::Document
	include Updateable
	#include Mongoid::Attributes::Dynamic



	field   :customer,          type:   String
	field   :process,           type:   String
	field   :environment,       type:   Hash,       default: {}
	field   :updated,           type:   Hash,       default: {}
	field   :created,           type:   Hash,       default: {}


	# def self.for_customer(cust)
	# 	CustomerEnvironment.for_customer(cust)
	# end
	#
	# def self.for_app(proc)
	# 	AppEnvironment.for_process(proc)
	# end


	def save
		super
		@@env = self
	end

end
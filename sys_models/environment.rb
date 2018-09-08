require '../sys_models/updateable'
require '../sys_models/ids_error'

#module IDSReader
	class Environment
		require 'json'
		include Mongoid::Document
		include Updateable
		#include Mongoid::Attributes::Dynamic



		field   :customer,          type:   String
    field   :process,           type:   String
    field   :in_queue_name,     type:   String
    field   :out_queue_name,    type:   String
    field   :error_queue_name,  type:   String
    field   :app_name,          type:   String
    field   :log_topic,         type:   String
    field   :log_key,           type:   String  
		field   :environment,       type:   Hash,       default: {}
		field   :updated,           type:   Hash,       default: {}
		field   :created,           type:   Hash,       default: {}


		# def self.for_customer(cust)
		# 	CustomerEnvironment.for_customer(cust)
		# end
		#
		# def self.for_app(customer, proc)
		# 	AppEnvironment.for_process(proc)
		# end


		def save
			super
			@@env = self
		end

	end
#end
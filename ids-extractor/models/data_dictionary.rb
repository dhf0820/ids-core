require '../sys_models/updateable'
require '../sys_models/ids_error'

#module IDSReader
	class DataDictionary
		require 'json'
		include Mongoid::Document
		include Updateable

		field   :name,          type: String
		field   :element_type,  type: String
		field   :description,   type: String
		field   :length,        type: Integer
		field   :picture,       type: String
		field   :updated,       type: Hash,     default: {}
		field   :created,       type: Hash,     default: {}


		# def initialize(name, length, element_type, picture)  #these problably be hash elements
		#
		# 	self.name = name
		# 	self.length = length
		# 	self.element_type = element_type
		# 	self.picture = picture
		#
		# end

		def DataDictionary.seed
			IDSReader::DataDictionary.new('pat_name', 30, :alphanumberic, nil).save

			IDSReader::DataElement.new('acct_num', 12, :numeric, nil).save
			IDSReader::DataElement.new('mrn',  8, :numeric, nil).save
			IDSReader::DataElement.new('pcp', 30, :alphanumeric, nil).save
			IDSReader::DataElement.new('cc1', 30, :alphanumeric, nil).save
			IDSReader::DataElement.new('cc2', 30, :alphanumeric, nil).save
			IDSReader::DataElement.new('cc3', 30, :alphanumeric, nil).save
			IDSReader::DataElement.new('dob', 10, :date, nil).save
			IDSReader::DataElement.new('ssn', 11, :alphanumeric, '/\d{3}-?\d{2}-?\d{4}/').save
			IDSReader::DataElement.new('admit_date', 10, :date, nil).save
		end
	end
#end

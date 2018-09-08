
require 'date'
require 'pry'

class Visit
	require 'json'
	include Mongoid::Document
	include Updateable


	field   :patient_id,        type: String
	field   :number,         type: String
	field   :admit_date,        type: Date
	field   :discharge_date,    type: Date
	field   :facility,          type: String
	field   :remote_id,         type: String
	field   :admission_type,    type: String
	field   :account_id,        type: String
	field   :comment,           type: String
	field   :status,            type: String
	field   :patient,           type: Hash, default: {}
	field   :updated,           type: Hash, default: {}
	field   :created,           type: Hash, default: {}

	def summary
		data = {}
		data['ids_id'] = self.id.to_s
		data['visit_num'] = self.number
		data['admit_date'] = self.admit_date
		data['disch_date'] = self.discharge_date
		data['remote_id'] =  self.remote_id
		data
	end

end
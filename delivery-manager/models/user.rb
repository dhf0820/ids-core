require '../sys_models/updateable'

class User
	require 'json'
	include Mongoid::Document
	include Updateable

	field :user_name,       type: String
	field :full_name,       type: String

	field :created,         type: Hash
	field :updated,         type: Hash

end
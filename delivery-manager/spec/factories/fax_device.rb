require './models/delivery_class'
require './models/fax_device'



FactoryBot.define do
	factory :fax_dev, class: FaxDevice do
		name { 'FAX' }
		description { 'FAX delivery' }
		after(:build) do |md|
			md.status = {}
			md.owner = {}
			md.created={}
			md.updated={}
			md.queue_details = {}
		end
	end
end

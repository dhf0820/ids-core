require './models/delivery_class'

FactoryBot.define do
	factory :fax_cls, class: FaxClass do
		name 'FAX'
		description 'Fax Delivery'
	end
end

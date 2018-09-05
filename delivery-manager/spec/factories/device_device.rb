

require './models/delivery_class'


FactoryBot.define do
	factory :none_dev, class: DeliveryClass do
		name  { 'None' } 
	end

	factory :mail_dev, class: DeliveryClass do
		name  { 'Mail' } 
		after(:build) do |d|

		end
	end

	factory :fax_dev, class: DeliveryClass do
		name { 'Fax' }
	end

	factory :athena_dev, class: DeliveryClass do
		name  { "Athena" }
	end
end
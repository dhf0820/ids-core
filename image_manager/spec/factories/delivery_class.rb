

require './models/delivery_class'

FactoryBot.define do
	factory :none, class: DeliveryClass do
		name 'None'
	end

	factory :mail, class: DeliveryClass do
		name 'Mail'
		after(:build) do |d|
			md = FactoryBot.build(:mail_dev)

		end
	end

	factory :fax, class: DeliveryClass do
		name 'Fax'
	end

	factory :athena, class: DeliveryClass do
		name  "Athena"
	end
end
require './models/delivery_class'

FactoryBot.define do
	factory :mail_cls, class: MailDeliveryClass do
		name { 'Mail' }
		description { 'Daily MAIL delivery' }
		after(:build) do |mc|
			mc.status = {}
			mc.devices=[]
			mc.created={}
			mc.updated={}
			mc.delivery_details = {}
		end

	end
end

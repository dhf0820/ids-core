require './models/delivery_class'
require './models/mail_delivery'

FactoryBot.define do
	factory :mail_dlv, class: MailDelivery do
		name { 'Mail' }
		description { 'Daily MAIL delivery' }
		after(:build) do |md|
			md.status = {}
			md.owner = {}
			md.created={}
			md.updated={}
			md.queue_details = {}
		end

	end
end

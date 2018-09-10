require 'spec_helper'
require './models/user'

FactoryBot.define do
	factory :theresa, class: User do
	user_name 'tfrench'
	full_name 'Theresa French'
	end

end
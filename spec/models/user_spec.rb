#require 'rails_helper'
require 'spec_helper'
require './spec/factories/user'



RSpec.describe User, type: :model do

	before :each do
	end

	it 'should find a user by user_name' do
		tf = FactoryBot.build(:theresa)
		tf.save
		usr = User.where(user_name: 'tfrench').first
		expect(usr.full_name).to eql 'Theresa French'
	end
end
#require 'rails_helper'
require 'spec_helper'
require './models/document_class'
require './spec/factories/document_class'


RSpec.describe DocumentClass, type: :model do
	let(:trans)  {FactoryBot.build(:trn_cls)}
	before :each do

	end

	it 'should find DocumentClass by code' do
		trans.save

		expect(DocumentClass.by_code('trans').id).to eql(trans.id)
	end
end
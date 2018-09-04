# RSpec without Rails
require "factory_bot"

RSpec.configure do |config|
	config.include FactoryBot::Syntax::Methods

	#config.before(:suite) do
		FactoryBot.find_definitions if FactoryGirl.factories.count == 0
	#end
end
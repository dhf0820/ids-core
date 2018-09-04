class IdsError  < StandardError
	attr_reader :code

	def initialize(msg = 'Default IDS Error', code = 500)
		super(msg)
		@code = code
	end
end
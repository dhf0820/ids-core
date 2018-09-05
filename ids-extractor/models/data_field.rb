class DataField
	attr_accessor :length, :name, :element_type, :value, :master

	def initialize(name, length, type = :alphanumeric, master = false)  #these problably be hash elements

		self.name = name
		self.length = length
		self.element_type = type
		self.master = master
		self.value = nil
	end
end
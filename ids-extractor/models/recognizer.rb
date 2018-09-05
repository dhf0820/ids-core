class Recognizer

	attr_accessor :name, :document_type, :document_class, :definition, :recognizer

	def initialize(name, document_type,  definition)  #these problably be hash elements

		self.name = name

		self.document_type = document_type
		self.definition = definition
		code_name = "./tmp/#{name}.rb"
		stat = File.open(code_name, 'w'){|f| f.write(definition)}
		#$log.debug "open #{code_name}"
		val = require code_name

		fname = "#{name.classify}"
		self.recognizer = fname.constantize

	end


	def Recognizer.process_file(text_file)
		#rec = recognizer.new
		#binding.pry
		"class method"
	end

	def process_file(text_file)
		#binding.pry
		puts "File: #{text_file}"
		rec = recognizer.new

	end

end
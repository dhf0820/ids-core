class Recognizers

		@@recognizers = HashWithIndifferentAccess.new 
		def initialize
			Recognizers.load_all
		end

		# def self.reload
		# 	binding.pry
		# 	Recognizers.clear
		# 	recognizers = DocumentDef.all
		# 	recognizers.each do |d|
		# 		Recognizers[d['name'].to_sym]   =  Recognizer.new(d['name'], d['document_type'], d['definition'])
		# 	end
		# end

# TODO load only recognizers identified in descriptor_list of confing.  Those are the only ones that this reader use
#
		def self.load_all
			Config.descriptor_keys.each do |key|   # Only descriptors required by this reader
        d = DocumentDef.by_name(key)
				Recognizers[d['name'].to_sym]   =  Recognizer.new(d['name'], d['document_type'], d['definition'])
				File.open(d['name'] + ".rb", 'w'){|f| f.write(d['definition'])}
				code_name = "./#{d['name']}.rb"
				load code_name
			end
			@@recognizers
			# end
			# Recognizers.clear
			# recognizers = DocumentDef.all
			# recognizers.each do |d|
			# 	Recognizers[d['name'].to_sym]   =  Recognizer.new(d['name'], d['document_type'], d['definition'])
			# 	File.open(d['name'] + ".rb", 'w'){|f| f.write(d['definition'])}
			# 	code_name = "./#{d['name']}.rb"
			# 	load code_name
			# end
			# @@recognizers
		end

		def self.find(name)
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@recognizers[name.to_sym]
		end

		def self.recognizers
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@recognizers
		end


		def self.recognizer(name)
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@recognizers[name.to_sym]
		end

		def self.[]=(k, v)
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@recognizers[k] = v
		end

		def self.[](k)
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@recognizers[k]
		end

		def self.each(&block)
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@recognizers.each(&block)
		end

		def self.has_key?(key)
			if @@recognizers.nil?
				Recognizers.load_all
			end
			@@erecognizers.has_key?(key.to_sym)
		end

# Remove non master tagged dataelements
		def self.clear
			@@recognizers = HashWithIndifferentAccess.new 
		end
	end

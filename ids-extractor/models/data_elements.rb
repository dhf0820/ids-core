#module IDSReader
  class DataElements
    @@elements = {}
    def initialize
      elements = DataDictionary.all
      elements.each do |d|
	      DataElements[d['name'].to_sym]   =  DataElement.new(d['name'], d['length'].to_int, d['element_type'], d['picture'])
      end
    end

    def self.elements
	    @@elements
    end

    def self.element(key)
			@@elements[key]
    end

    def self.[]=(k, v)
      @@elements[k] = v
    end
    
    def self.[](k)
      @@elements[k]
    end

    def self.keys
      @@elements.keys
    end

    def self.each(&block)
      @@elements.each(&block)
    end
    
    def self.has_key?(key)
      @@elements.has_key?(key)
    end
    
# Remove non master tagged dataelements    
    def self.clear
      @@elements.each do |k, v|
          k.value = nil
      end
    end
  end
#end
      

    
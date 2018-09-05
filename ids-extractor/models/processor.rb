require 'active_support/core_ext'
#module IDSReader
  class Processor
    attr_reader :documents
    attr_accessor :config
    
    # Create a new document processor that reads from a queue/directory for a new raw file and extracts identified reports found in each file. 
    # Finds and loads all descriptor files in the descriptors folder. Then processes each raw file
    # ==== Creates  
    # * @descriptor_path - where to find the descriptors
    # * @config - Configuration of this processor. Allows multiple processors to be handled at one time
    # * @documents - Array to hold information about ewach document found in the raw file 
#    def initialize(config_path, mode, options = {}) 
    def initialize(configuration)
      #puts "Initializing Processor with options: #{options}"
      #$descriptors = nil
      @config = Config.active #$configutation
      @processor_name = configuration.processor_name


      #
      # @log = Logging::Logger['Processor']
      #
      # unless options[:log_level].nil? or options[:log_level] == ""
      #   #@log.warn "  @@@  Setting logging level to #{options[:log_level]}"
      #   #@log.level = options[:log_level]
      # else
      #   puts "  @@@  Setting default log level: debug"
      #   #@log.level = :debug
      # end

      recognizers    # initialize all descriptors


      @current_document = nil

      #@log.info "#{processor_name} created in #{$configuration.mode} mode.}"
    end

    def processor_name
      @processor_name
    end

    def process(file_name)
      #@log.info "Processing #{file_name}"
      self.document_path = file_name

      @current_document = Document.new(:file_to_process => file_name)

      @current_document.process_document unless file_name.nil?
      @current_document
    end

#Establish the name for the raw document to be processed. Use     
    def document_path=(current_document_path)
      @current_document = Document.new(:file_to_process => current_document_path)
      puts "set DocumentPath: #{@current_document}"
      @current_document
    end

# Sets the document to be worked on. Creates and returns the Document Object supporting the file.    
    def document_path(current_document_path)
#      @log.info("Set current document: #{current_document_path}")
      @current_document = Document.new(:file_to_process => current_document_path)
    end

# The current Document object that results from setting the document_path            
    def document
      @current_document
    end

# Process all the reports found in the raw document. Find each report, determine the type and extract all the data. 
# Uses either the raw document set with document_path or the passes path to a raw document.   
    def process_document(current_document_path = nil)
      @current_document = document_path(current_document_path) unless current_document_path.nil?
      @current_document.process_document unless document.nil?
    end
    
    def process_file(current_document_path)
      process_document(current_document_path)
    end
    
    
    def process_buffer(buffer)
      #puts "    ProcessBuffer"
      @current_document = Document.new(:lines => buffer.split("\n"))
#$log.debug "split the document calling process_document"
     # puts "\nProcessBuffer calling current_document.process_document"
      @current_document.process_document
#$log.debug "returning: #{[@current_document.reports.count, @current_document.unknown_reports.count] }"
      [@current_document.reports.count, @current_document.unknown_reports.count]
      @current_document
    end

    #returns all recognizers
    def reload_recognizers
      Recognizers.load_all
      #Recognizers.recognizers
    end

    def recognizers
      Recognizers.recognizers
    end

    def recognizer(name)
      r = Recognizers.recognizer(name)
      return nil if r.nil?
      r.recognizer
      r
    end


    def descriptor_keys
      Config.descriptor_keys
    end

# === Descriptors
# Each possible report contained in a raw file is defined by a ruby file that
#     def descriptors
#       binding.pry
#       return Config.descriptors unless Config.descriptors.nil?
#       begin
#          descriptor_code = []
#          Config.descriptors_defined.each do |name|
#            rec = Config.recognizer(name)
#            descriptor_code << rec.recognizer
#          end
#          Config.add :descriptors, descriptor_code
#        end
#       Config.descriptors
#     end
#
#     def descriptor_list
#       Config.descriptors_defined
#     end
   end
#end


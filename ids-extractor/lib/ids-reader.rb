$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

  require 'rubygems'
  require 'fileutils'
  require 'active_support'
  require 'andand'
require 'pry'
require 'bunny'

  
#  require 'fileutils'
  require 'logging'

require './models/config.rb'
require './models/exceptions.rb'
require './models/data_element.rb'
require './models/data_dictionary'
require './models/descriptor.rb'
require './models/document.rb'
require './models/page.rb'
require './models/processor.rb'
require './models/report.rb'
require './models/data_elements.rb'
require './models/environment'
require './models/exceptions'
require './models/document_def'
require './models/recognizers'
require './models/recognizer'

require './lib/string_ext.rb'

require './lib/vs_log'

#module IDSReader
  FORM_FEED_CHAR = "\f"
  BLANK_CHARS = " \t\b\n"
  END_OF_REPORT = 1
  PAGE_NUMBER = 2
  $configuration = nil
  $reader = nil

  class Reader
    def initialize(configuration) #process_def, options = {})
      #puts "Reader.init Version: #{VERSION} process_def: #{process_def} options: #{options}"
      options = {}
      # if configuration.nil?
      #   $log.warn "@configuration was not set using default reader"
      #   $configuration = @configuration = Config.new( 'reader')
      # else
      #   @configuration = configuration
      # end

      processor_name = configuration.processor_name

      # puts "    Reader $configuration: #{$configuration.inspect}"
      #options[:name] = configuration.processor_name unless options[:name]
      # options[:base_path] = $configuration.base_path

      @processor = Processor.new(configuration) if @processor.nil?
      $reader = @reader = self
      #puts "ProcessorName = #{options[:name]}"


    end

    def reader
      @reader
    end

    def configuration
      @configuration
    end


    # def config(key)
    #   Config.current(key)
    # end
    def create_processor(options = {})
      options[:name] = $configuration.processor_name unless options[:name]

      @processor = Processor.new(options) if @processor.nil?
    end


    def processor
      @processor
    end

    # may not need
    def processor_name
      @configuration.processor_name
    end

    def queue_name
      @configuration.queue_name
    end

    def queue_to
      @configuration.queue_to
    end

    def mode
      @configuration.runtime_mode
    end

    def mode=(new_mode)
      @configuration.runtime_mode = new_mode
    end

    def base_path
      @configuration.base_path
    end

  end
  
#end



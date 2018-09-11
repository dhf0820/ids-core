puts "Current: #{Dir.pwd}"

require '../sys_lib/work_queue'
require '../sys_models/app_environment'
require '../sys_models/customer_environment'
require './lib/version'
require './models/recognizer'
require './models/recognizers'

#module IDSReader
##
# Allows the global access to all application configuration values.
# The configure_environment must be called before anything to specify the
# environment, processor name and runtime mode
	class Config
    @@current_config = {}
		@@valid_descriptors= []

    def initialize() # env_folder)
      @customer_name = ENV['CUSTOMER']
      @service_name = ENV['SERVICE']

			@@config = @config = self


			#@@current_config['db_connection'] = $db_connection
			#STDERR.puts "Database connection: #{@@current_config['db_connection'].inspect}"
			## Configure the system
			#puts "puts Starting for Customer = #{$customer}"
			#STDERR.puts "Starting for Customer = #{$customer}  Getting system environment"


      @process = AppEnvironment.for_process(@customer_name, @service_name)

      @sys = @process.sys
      @sys_env = @sys.environment
      @env = @process.environment
      @proc = @process
      @proc_env = @process.environment



			amqp_connection = make_rabbit_connection

			$log = VsLog.new()

			@in_queue =  WorkQueue.new( in_queue_name)
			@out_queue = WorkQueue.new( out_queue_name)
      #@unknown_queue = WorkQueue.new(unknown_queue_name)



			DataElements.new
			load_descriptor_list

      x = Recognizers.load_all #new(  )
      $log.info "#{@service_name} version #{VERSION} is starting using #{amqp_name}"

		end

    def make_rabbit_connection
      rabbit = @sys.amqp
      if rabbit.nil?
        puts "!!!! Using local AMQP server "
      end
      amqp_connection = Bunny.new(rabbit)
      @rabbit_connection = amqp_connection
      STDERR.puts "AMQP Connection: #{amqp_connection.inspect}"
      @rabbit_name = rabbit.split('/')[3]
      amqp_connection.start

      #@proc.amqp_connection = amqp_connection
      #@@current_config[:amqp_connection] = $amqp_connection

      amqp_connection
    end

    def sys
      @sys
    end

    def sys_env
      @sys.environment
    end

    def proc
      @proc
    end

    def proc_env
      @proc.environment
    end

    def process
      @proc.process
    end

    # def customer
    #   @proc.customer
    # end

    # def in_queue_name
    #     @proc.in_queue_name
    # end



    #
        # def out_queue_name=(value)
	     #    @proc.environment[:out_queue] = value
        # end

        # def out_queue_name
	      #   @proc.environment[:out_queue]
        # end

        # def in_queue_name=(value)
	     #    self.environment[:in_queue] =  value
        # end

        # def in_queue_name
	      #   @proc.environment[:in_queue]
        # end

        # def error_queue_name=(value)
	     #    self.environment[:error_queue] =  value
        # end

        # def error_queue_name
	      #   @proc.environment[:error_queue]
        # end

        # def app_name=(value)
	     #    self.environment[:app_name] = value
        # end

        # def app_name
	      #   @proc.environment[:app_name]
        # end

        # def log_key=(value)
	     #    self.environment[:log_key] = value
        # end

        # def log_key
	      #   @proc_env[:log_key]
        # end

        # def log_topic=(value)
	     #    self.environment[:log_topic] = value
        # end

        # def log_topic
	      #   @proc.environment[:log_topic]
        # end

        def in_queue=(queue)
	        @in_queue = queue
        end

        def in_queue
	        @in_queue
        end

        def out_queue=(queue)
	        @out_queue = queue
        end

        def out_queue
	        @out_queue
        end

        def err_queue=(queue)
	        @error_queue = queue
        end

        def err_queue
	        @error_queue
        end

        def amqp
	        @proc.amqp
        end

        def amqp_connection=(connection)
	        @rabbit_connection = connection
        end

        def amqp_connection
	        @rabbit_connection
        end

        def amqp_name=(name)
	        @rabbit_name = name
        end

        def amqp_name
	        @rabbit_name
        end

		def service
			@service_name
		end

        def customer
	        @@customer_name
        end

		def processor_name
			@proc.process
		end

        def remote_url

	        @proc.remote_url
        end

        def remote_token
	        @proc.remote_token
        end




    def self.active
      @@config
			#@proc
		end

		def self.current
			@@config
		end
		#
		# def self.current(key)
		# 	binding.pry
		# 	@proc[key]
		# end

    # ordered list of valid descriptors.  Use this list to check current document for each possible recognizer in the proper order.
		# def self.descriptors_defined
		# 	@@valid_descriptors =  @proc.descriptors
		# end

		# def reset_environment
		# 	$log.info "!!!  RESETTING Module #{@proc} environment"
		# 	$next_queue.close_channel   # shutdown current next queue channel to set up whatever configurations says to
		# 	# to run with different inbound queue spin up another process
		#
		# 	# to change  customer spin up new module with proper configuration defiled
		#
		# 	$log.debug "Getting module: #{@proc} environment"
		# 	env = Environment.for_process(@proc.to_sym)
		# 	if env.nil?
		# 		$log.fatal "App #{@proc} Environment is not configured"
		# 		raise InvalidConfiguration.new( "\nThe [#{@proc}] process is not configured in the Environment database. Please do so and restart.\n")
		# 	end
		#
		# 	env.envs.each do |key, val|
		# 		@@current_config[key.to_sym] = val
		# 	end
		# 	$next_queue = NextQueue.new(amqp_connection, next_queue)
		# 	add(:next_queue, $next_queue)
		#
		# 	DataElements.new
		# 	load_descriptor_list
		# 	Recognizers.load_all #new(  )
		# end


		def self.recognizers
			Recognizers.recognizers
		end

		def self.recognizer(name)
			Recognizers.recognizer(name)
		end

        def recognizers
	        Recognizers.recognizers
        end

        def recognizer(name)
	        Recognizers.recognizer(name)
        end

        #ordered list of valid descriptors.  Use this list to check current document for each possible recognizer in the proper order.
    def self.descriptor_keys
      @@config.descriptor_keys
			#@@config.proc_env[:descriptor_keys]
		end


		#
		# def inqueue_name
		# 	@@current_config[:in_queue]
		# end
		#
		# def inbound_queue
		# 	@@current_config[:inbound_queue]
		# end
		#
		# def next_queue
		# 	@@current_config[:next_queue]
		# end

		# def init_logging
		# 	Logging.init %w(DEBUG9 DEBUG8 DEBUG7 DEGUB6 DEBUG5 DEBUG4 DEBUG3 DEBUG2 DEBUG1 DEBUG INFO WARN ERROR FATAL)  if $logging_initialized.nil?
		# 	$logging_initialized = true
		# 	Logging.logger.root.level = :debug4
		# 	@log_file = @base_path + @config['log_file']
		# 	Logging.logger.root.appenders = Logging.appenders.rolling_file('jsonlog',
		# 	                                                               :filename => @log_file + '.json',
		# 	                                                               :level => :warn,
		# 	                                                               :age => :daily,
		# 	                                                               :layout => Logging.layouts.json
		# 	),
		# 		Logging.logger.root.appenders = Logging.appenders.rolling_file('rollfile',
		# 		                                                               :filename => @log_file,
		# 		                                                               :age => :daily
		# 		),

		# 		Logging.appenders.stdout('stdout',
		# 		                         :key => "value",
		# 		                         :level => :error
		# 		#:layout => Logging.layouts.pattern
		# 		)
		# 	@active_config = self
		# end
##
# Specify the values required to determine the proper configuration information
# to be used.
# This method also configures the specified reader's configuration and the {DataElements}
# that maintain the meta data extracted from the document.
#
# @param [String] the name of the environment variable containing the base location
# of the application.
# @param [String] the name of the processor being run. This name is used to find the
# configuration file. It should be placed in the environment specified
# directory/processors/processor_name/mode
# @param [String] the mode the application will rung in. Values are live or test


# def self.configure(proc_foloder)
#   @current_config = Config.new()
# end

		# def add(key, value)
		# 	@@current_config[key.to_sym] = value
		# end
		#
		# def get(key)
		# 	@@current_config[key.to_sym]
		# end
		#
		# def active_config
		# 	@@current_config
		# end
		#
		# def processor_name
		# 	get(:processor_name)
		# end
		#
		# def environment()
		# 	raise NameError.new("No runtime environment has been established") if @config.nil?
		# 	[@env_path, @processor_name, runtime_mode]
		# end
		#
		# def amqp_connection
		# 	get(:amqp_connection)
		# end
		#
		# def self.processor_name
		# 	self.current(:processor_name)
		# end
		#
		#
		# def config_path
		# 	@config_path
		# end
		#
		# def system_path
		# 	@env_path
		# end

##
# Determines the base path for the application from the config file. If specified it must include the
# runtime mode if modes are used in the application.
#
# @param none
# @return [string] the path of the top level of the application including the run mode
#     def base_path
#       @base_path
#     end
#
#     def queue_name
#       c = @config['queue_name'] || self.processor_name
# #      puts "c = #{c} mode = #{@@mode}"
#       c = "#{c}_test" if self.runtime_mode == 'test'
# #      puts "after #{c}"
#       c
#     end
#
#     def queue_to
#       q = @config['queue_to']
#       q = "#{q}_test" if self.runtime_mode == 'test'
#       q
#     end
#
#     def archive_path
#       a = @config['archive_path'] || "archive/"
#       return a if (a[0].chr == '/'|| a[0] == '~')  #full path given
#       base_path + a
#     end

# def log_path
#   a = @config['log_path'] || "logs/"
#   return a if a[0].chr == '/'  #full path given
#   base_path + "#{a}"
# end

# def log_file
#   base_path + @config['log_file'] || "#{base_path}logs/reader.log"
# end
#
# def tmp_path
#   a = @config['tmp_path'] || "tmp/"
#   return a if (a[0].chr == '/' || a[0] == '~')
#  #return File.expand_path(a)  if (a[0] == '~') #full path given
#   base_path + a
# end
#
# def pending_path
#   a = @config['pending_path'] || "tmp/"
#   return a if (a[0].chr == '/' || a[0] == '~')  #full path given
#   base_path + a
# end
#
# def output_path
#   a = @config['output_path'] || "tmp/"
#   return a if (a[0].chr == '/'|| a[0] == '~')  #full path given
#   base_path + a
# end

		def runtime_mode
			Config.get(:mode) || 'test'
		end

		def mode
			runtime_mode
		end

		def runtime_mode=(value)
			@config['mode'] = value if %W(test live).include?(value)
		end

# def descriptor_path
#   base_path + "descriptors/"
# end

		# def descriptors=(descriptor)
		# 	@descriptors = descriptor
		# end
#ordered list of valid descriptors.  Use this list to check current document for each possible recognizer in the proper order.
    


    # def descriptors_keys
		# 	@proc.descriptor_keys
		# end

		def create_processor
			@processor = Processor.new($config) if @processor.nil?
		end

		def processor
			@processor
		end

		def processor=(new_processor)
			@processor = new_processor
		end


##
# Allows an application to add additional runtime configuration to the config environment. The current
#  configuration is passed to most objects created allowing them access to config information
#
# @param [string] key to associate with the value
# @param [object] value being save to be retrieved with the key value
#
# @return [bject] the value specified
#
# @api public
		def self.add(key, value)
			@@current_config[key] = value
		end

##
# Finds any config value set with that key using add, or nil if the key is not set.  Normal config values maintained in the
# configuration.yml file are available in their raw format. It is best to use the helper methods instead of
# the raw versions.
#
# @param [String] key value to use in finding the data
#
# @return [Object] the object found by the given key
#
# @api public
		def self.get(key)
			@@current_config[key]
		end

		private


		def load_descriptor_list

		end

    def method_missing(m, *args, &block)
     # puts "There's no method called #{m} -  args: #{args}  in config -- Using app_environment."

      @proc.send(m, *args, &block)
      #@proc_env[m.to_sym]
    end

	end
#end
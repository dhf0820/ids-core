puts "Current: #{Dir.pwd}"
require '../sys_lib/work_queue'
require '../sys_models/app_environment'
require '../sys_models/customer_environment'
require '../sys_models/remote_repository'
require './lib/version'
require '../sys_models/chart_archive_class'

require '../sys_lib/vs_log'

#module IDSReader
##
# Allows the global access to all application configuration values.
# The configure_environment must be called before anything to specify the
# environment, processor name and runtime mode
class Config
  @@current_config = {}
  @@config = nil
  @time_initialized =  nil
  def initialize() # env_folder)
    #start_time = Time.now
    #puts "\n In initializing Config"
    @customer_name = ENV['CUSTOMER']
    @service_name = ENV['SERVICE']

    @@config = self
    @time_initialized = DateTime.now
    @process = AppEnvironment.for_process(@customer_name, @service_name)

    @sys = @process.sys
    @sys_env = @sys.environment
    @env = @process.environment
    @proc = @process
    @proc_env = @process.environment


    @amqp_connection = make_rabbit_connection

    $log = VsLog.new()

    @in_queue =  WorkQueue.new(in_queue_name)
    @out_queue = WorkQueue.new(out_queue_name)
    @err_queue = WorkQueue.new(error_queue_name)
    # $next_queue = NextQueue.new($amqp_connection, next_queue)
    # add(:next_queue, $next_queue)
    
    @chart_archive_class = ChartArchiveClass.first
    if @chart_archive_class.nil?
      puts "   @@@ Create ChartArchiveClass"
      @chart_archive_class = ChartArchiveClass.new
      @chart_archive_class.save 
    end

    $log.info "#{@service_name} version #{VERSION} is starting using #{amqp_name}"
    #$log.info "Config time: #{Time.now - start_time}ms\n\n"
  end

  def make_rabbit_connection
    rabbit = @sys.amqp
    if rabbit.nil?
      puts "!!!! Using local AMQP server "
    end
    connection = Bunny.new(rabbit)
    @rabbit_connection = amqp_connection
    #STDERR.puts "AMQP Connection: #{amqp_connection.inspect}"
    @rabbit_name = rabbit.split('/')[3]
    connection.start

    connection
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

  def time_initialized 
    @time_initialized
  end

  def chart_archive_class
    if @chart_archive_class
      return @chart_archive_class
    else
      @chart_archive_class = ChartArchiveClass.new
    end
  end

  def chart_archive_device
    @chart_archive_class.device
  end

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
    connection = @proc.amqp
    @rabbit_name = connection.split('/')[3]
    connection
  end

  def amqp_connection
    @amqp_connection
  end

  def amqp_name
    #amqp.split('/')[3]
    @rabbit_name
  end

  def service
    @service_name
  end

  def customer
    @customer_name
  end

  def processor_name
    @proc.process
  end

  def remote=(value)
    @remote = value
  end

  def remote
    if @remote.nil?
      @remote = RemoteRepository.new
      
    end
    
    @remote
  end

  def remote_url
    @sys.remote_url
  end

  def remote_token
    @sys.remote_token
  end

  def self.active
    @@config
    #@proc
  end



  # def init_logging
  #   Logging.init %w(DEBUG9 DEBUG8 DEBUG7 DEGUB6 DEBUG5 DEBUG4 DEBUG3 DEBUG2 DEBUG1 DEBUG INFO WARN ERROR FATAL)  if $logging_initialized.nil?
  #   $logging_initialized = true
  #   Logging.logger.root.level = :debug4
  #   @log_file = @base_path + @config['log_file']
  #   Logging.logger.root.appenders = Logging.appenders.rolling_file('jsonlog',
  #                                                                   :filename => @log_file + '.json',
  #                                                                   :level => :warn,
  #                                                                   :age => :daily,
  #                                                                   :layout => Logging.layouts.json
  #   ),
  #     Logging.logger.root.appenders = Logging.appenders.rolling_file('rollfile',
  #                                                                     :filename => @log_file,
  #                                                                     :age => :daily
  #     ),

  #     Logging.appenders.stdout('stdout',
  #                               :key => "value",
  #                               :level => :error
  #     #:layout => Logging.layouts.pattern
  #     )
  #   @active_config = self
  # end

  def runtime_mode
    Config.get(:mode) || 'test'
  end

  # def mode
  #   runtime_mode
  # end

  # def runtime_mode=(value)
  #   @config['mode'] = value if %W(test live).include?(value)
  # end

  def self.add(key, value)
    @@current_config[key] = value
  end

  def self.get(key)
    @@current_config[key]
  end


  private

  def method_missing(m, *args, &block)
    #puts "There's no method called #{m} -  args: #{args}  in config -- Using app_environment."
    @proc.send(m, *args, &block)
    #@proc_env[m.to_sym]
  end

end

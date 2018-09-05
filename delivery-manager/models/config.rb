require_relative '../lib/vs_log'
require_relative 'environment'
require_relative 'app_environment'
require_relative 'customer_environment'
require_relative '../lib/in_queue'
require_relative '../lib/work_queue'
#require_relative '../lib/out_queue'




##
# Allows the global access to all application configuration values. 
# The configure_environment must be called before anything to specify the 
# environment, processor name and runtime mode
class Config

    @@config = nil

  def initialize # env_folder)
    @@config = self

    @customer_name = ENV['CUSTOMER']
    @service_name = ENV['SERVICE']


    if @customer_name.nil?
        STDERR.puts "Config customer is default to dev"
        @customer_name = 'dev'
    end

    @process = AppEnvironment.for_process(@customer_name, @service_name)
    @env = @process.environment

    initialize_rabbit

    #puts "Service Name = #{service_name}"
    initialize_queues
end

def initialize_rabbit
    rabbit = amqp
    if rabbit.nil?
        puts "!!!! Using local AMQP server "
    end
    @amqp_connection = Bunny.new(rabbit)
    @amqp_connection.start
    $log = VsLog.new

  end

  def initialize_queues()
      #@in_queue  = InQueue.new(in_queue_name)
      @in_queue  = WorkQueue.new(in_queue_name)
      #@out_queue  =WorkQUeue.new(out_queue_name)
  end


  def sys_env
      @process.sys_env.environment
  end

  def env 
      @process.environment
  end

  def log
      $log
  end

  def user
      env[:user]
  end

  def password
      env[:password]
  end
  
  def delay_seconds
      env[:delay_seconds]
  end
  
  def amqp_connection
      @amqp_connection
  end

  def in_queue_name
      env[:in_queue_name] #environment[:in_queue]
  end

  def in_queue
    @in_queue
  end

  def out_queue_name
      env[:out_queue_name]  #@process.out_queue_name #environment[:out_queue]
  end

  def out_queue
      @out_queue
  end

  def amqp
      @process.amqp
  end

  def app_name
      @process.app_name
  end

  def log_key
      @process.log_key
  end

  def process
      @process.process
  end

  def delivery_class_names
      env['delivery_class_names']  #delivery_class_name
  end

  def delivery_class=(value)
      @delivery_class = value
  end

  def delivery_class
      @delivery_class
  end

  def service_name
      @service_name
  end

  def app_environment
      @process.environment
  end

  def sys_environment
      @sys_env.environment
  end

  def self.active
      raise IdsError.new "Configuration has not been initialized" if @@config.nil?
      @@config
  end

  def mode
      c_mode = @process.mode
      if c_mode.nil?
      return :live
      else
      return :test
      end
  end

  def user
      env['user']
  end

  def password
      env['password']
  end

  def product_id
      env['product_id']
  end

  def api_base_url
      env['api_base_url']
  end



  def add(key, value)
      @process.environment[key.to_sym] = value
  end
  
  def get(key)
      @process.environment[key.to_sym]
  end

  def amqp_connection
      @amqp_connection
  end

  def config_path
      @config_path
  end

  def system_path
      @env_path
  end


private


end

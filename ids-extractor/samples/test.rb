require 'logging'
require 'pry'
include Logging.globally


Logging.logger.root.level = :debug

 Logging.logger.root.appenders = Logging.appenders.rolling_file('rollfile',
   :filename => 'default.log',
   :age => :daily,
   :layout => Logging.layouts.json
),

Logging.appenders.stdout('stdout',
    :key => "value", 
    :level => :error
    #:layout => Logging.layouts.pattern
)

#Logging.logger.root.appenders = %w[stdout, rollfile]  

  #Logging.appenders.file('output.log')

  # log1 = Logging.logger['Log1']
  # log2 = Logging.logger['Log2']
  # log3 = Logging.logger['Log3'] 

  # log2.add_appenders (
  #   Logging.appenders.stdout,
  #   Logging.appenders.rolling_file('rolling.out')
  # )
  
        # @log_file = @config.log_file
  # Logging.appenders.stdout(
  #  'stdout',
  #  :level => :error
  #  #:layout => Logging.layouts.pattern
  # )

  # Logging.appenders.rolling_file(
  #  'readerlog',
  #  # :filename => 'default',
  #  :age => :daily,
  #  :layout => Logging.layouts.json
  # )


 log1 = Logging.logger['Log1']
 log2 = Logging.logger['log2']
  # log1.add_appenders(
  #   Logging.appenders.stdout(
  #      'stdout',
  #      :level => :error
  #      #:layout => Logging.layouts.pattern
  #   ),

  #   Logging.appenders.rolling_file(
  #      'readerlog',
  #      :filename => 'Log1',
  #      :age => :daily,
  #      :layout => Logging.layouts.json
  #   )
  # )

  # log3.level = 'debug'

  # log2.warn "this is a warning to rolling log"
  log1.error "this is an error log new"
  log1.warn 'this is warning on log 1 dhf'
  log1.info "this message will not get logged new"
   log2.warn "nor will this message new"
  log1.debug "log 1 debug"
  log2.debug "log 2 debug"
  # log3.info "but this message will get logged"
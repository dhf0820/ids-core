require 'rubygems'
require 'bundler/setup'
ENV['RACK_ENV'] = 'test'

require 'pry'
require 'rspec'
require 'mongoid'
#require 'active_record'
require 'database_cleaner'
# require File.expand_path("../../lib", __FILE__)
# require File.expand_path("../../models", __FILE__)
#
ENV['MONGO_ENV'] = $mongo_env = 'test'
ENV['CUSTOMER'] ='test'
ENV['SERVICE'] = 'reader'

require './lib/mongo_connection'
#require './lib/db_connection'

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../models')
require 'thread'
require 'ids-reader'
#include IDSReader
# FORM_FEED_CHAR = "\f"
# BLANK_CHARS = " \t\b\n"
# END_OF_REPORT = 1
# PAGE_NUMBER = 2

#require 'spec/logging_helper'
#Spec::Runner.configure do |config|
# include Spec::LoggingHelper
# config.capture_log_messages
#end
RSpec.configure do |config|
   #config.filter_run :focus => true
   config.expect_with :rspec

   config.before(:suite) do
      DatabaseCleaner[:mongoid].clean_with :truncation
   end

   config.before(:suite) do
      DatabaseCleaner[:mongoid].strategy = :truncation
      DatabaseCleaner[:mongoid].clean_with(:truncation)
   end

   config.before(:all) do
      # Clean before each example group if clean_as_group is set
      if self.class.metadata[:clean_as_group]
         DatabaseCleaner[:mongoid].clean
      end
   end

   config.after(:all) do
      # Clean after each example group if clean_as_group is set
      if self.class.metadata[:clean_as_group]
         DatabaseCleaner[:mongoid].clean
      end
   end

   config.before(:each) do
      # Clean before each example unless clean_as_group is set
      unless self.class.metadata[:clean_as_group]
         DatabaseCleaner[:mongoid].start
      end
   end

   config.after(:each) do
      # Clean before each example unless clean_as_group is set
      unless self.class.metadata[:clean_as_group]
         DatabaseCleaner[:mongoid].clean
      end
   end
   # config.before(:all) do
   #    DatabaseCleaner.clean_with :deletion
   # end
end

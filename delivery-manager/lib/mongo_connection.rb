require 'mongoid'
puts "@@@@ Mongo using #{ENV['MONGO_ENV']}"
Mongoid.load! './config/mongoid.yml', ENV['MONGO_ENV']
#Mongoid.raise_not_found_error = false
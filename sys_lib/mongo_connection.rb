require 'mongoid'
puts "Using MONGO_ENV: #{ENV['MONGO_ENV']}"
Mongoid.load! './config/mongoid.yml', ENV['MONGO_ENV']
Mongoid.raise_not_found_error = false
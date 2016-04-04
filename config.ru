#\ -p 9293 --host 0.0.0.0
require 'sinatra/base'
require 'active_record'
require 'sqlite3'
require 'tilt/haml'
require 'uri'
require 'HTTParty'

ENV['RACK_ENV']='production'
ENV['TEST_ENV']='integration'
ENV['DEFAULT_CONTENT_TYPE'] = 'application/json;charset=UTF-8'
ENV['HEADER_DELIMITER'] = ":==:"
ENV['REPLACE'] = "1"
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::DEBUG

db = YAML.load_file(File.expand_path('./config/database.yml'))['development']
ActiveRecord::Base.establish_connection db

Dir.glob('./{helpers,controllers,models}/*.rb').each do |file|
  require file
end

map('/') { run ApplicationController}
map('/mock') { run MockServerController}

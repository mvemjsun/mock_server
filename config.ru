#\ -p 9293 --host 0.0.0.0
require 'sinatra/base'
require 'active_record'
require 'sqlite3'
require 'tilt/haml'
require 'uri'
require 'HTTParty'

require 'logger'
Logger.class_eval { alias :write :'<<' }
$logger = ::Logger.new(::File.new("logs/app.log","a+"))

ENV['TEST_ENV']='production'
ENV['DEFAULT_CONTENT_TYPE'] = 'application/json;charset=UTF-8'
# Once the delimiter is set then it can only be changed if all mock db mock_data_response_headers are updated to use the new header
ENV['HEADER_DELIMITER'] = ":==:"
ENV['REPLACE'] = "1"
ENV['MAX_UPLOAD_SIZE'] = '500000'
# Integer setting the latency of responses, Global setting
ENV['LATENCY'] = '0'
ActiveRecord::Base.logger = Logger.new('logs/app.log')
ActiveRecord::Base.logger.level = Logger::DEBUG

db = YAML.load_file(File.expand_path('./config/database.yml'))['development']
ActiveRecord::Base.establish_connection db

Dir.glob('./{helpers,controllers,models}/*.rb').each do |file|
  require file
end

map('/') { run ApplicationController}
map('/mock') { run MockServerController}

#\ -p 9293 --host 0.0.0.0
require 'sinatra/base'
require "sinatra/cookies"
require 'active_record'
require 'sqlite3'
require 'tilt/haml'
require 'uri'
require 'HTTParty'

require 'logger'
Logger.class_eval { alias :write :'<<' }
$logger = ::Logger.new(::File.new("logs/app.log","a+"))

$logger.level = Logger::DEBUG

ENV['ENVIRONMENT'] ||= 'development'
ENV['REQUEST_LOGGING']="1"
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

db = YAML.load_file(File.expand_path('./config/database.yml'))[ENV['ENVIRONMENT']]
ActiveRecord::Base.establish_connection db

Dir.glob('./{helpers,controllers,models}/*.rb').each do |file|
  require file
end

# Needed for any API calls that may require authentication etc
$user_id = ENV['MOCK_USERID'].nil? ? '' : ENV['MOCK_USERID']
$user_password = ENV['MOCK_PASSWORD'].nil? ? '' : ENV['MOCK_PASSWORD']
#
# Load any existing routes with wildcards
#
$wild_routes = {}
$wild_routes = WildRoutes.get_wild_routes_if_any

map('/') { run ApplicationController}
map('/mock') { run MockServerController}
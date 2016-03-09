#\ -p 9292 --host 0.0.0.0
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
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::DEBUG
Dir.glob('./{helpers,controllers,models}/*.rb').each do |file|
  require file
end

map('/mock') { run MockServerController}
map('/rt') { run ReleaseTrainController}
map('/') { run ApplicationController}

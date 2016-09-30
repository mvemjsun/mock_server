# encoding: utf-8
require 'uri'

class Httprequestlog < ActiveRecord::Base

  validates :request_http_verb, presence: true
  validates :request_url, presence: true
  validates :request_headers, presence: true
  validates :request_environment, presence: true

  #
  # Save the incoming http request, save only the headers and the body along with the request method and query string and url
  # @param [Hash] request sinatra request hash
  # @return nil
  #
  def save_http_request(request)
    self.request_http_verb = request.env['REQUEST_METHOD']
    self.request_url = request.env['PATH_INFO']
    self.request_query_string = request.env['QUERY_STRING']

    output = ''
    request.env.each do |k, v|
      output << "#{k} => #{v} \n" unless k.match(/[rack,sinatra]/)
    end
    self.request_headers = output

    body_text = request.body.read
    if body_text && body_text.length > 0
      self.request_body = URI.decode(body_text)
    else
      self.request_body = ''
    end
    self.request_environment = ENV['TEST_ENV']
    self.request_http_verb = self.request_http_verb.upcase
    self.created_at = Time.new.strftime('%Y-%m-%d %H:%M:%S')
  end

  #
  # Deletes all rows from the httprequestlogs table
  #
  def self.clear_request_log
    ActiveRecord::Base.connection.raw_connection.execute('DELETE FROM HTTPREQUESTLOGS')
  end

  #
  # Get the request logs from a start date time to the end date time. If no end datetime is specified the current
  # date time is assumed. If no start time is provided then time 10 minutes ago is taken.
  # @param [String,[String]] start_datetime and end_datetime in format ('%Y-%m-%d %H:%M:%S', ...)
  # @return [JSON] request log data in JSON format or empty JSON if no data
  #
  def self.get_request_log(start_datetime=(Time.now - (600)).strftime('%Y-%m-%d %H:%M:%S'),
      end_datetime=Time.new.strftime('%Y-%m-%d %H:%M:%S'),
      matching=nil
  )
    if matching.nil?
      data = where("created_at >= :start_datetime AND created_at <= :end_datetime",
                   {start_datetime: start_datetime, end_datetime: end_datetime})
    else
      match_string = '%' + matching + '%'
      data = where("(created_at >= :start_datetime AND created_at <= :end_datetime) AND request_url like :match_string",
                   {start_datetime: start_datetime, end_datetime: end_datetime, match_string: match_string})
    end

    if data.any?
      return data.to_json
    else
      return '[{"message" : "No request logs found"}]'
    end
  end
end




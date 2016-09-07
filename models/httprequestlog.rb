# encoding: utf-8
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
    request.env.each do |k,v|
      output << "#{k} => #{v} \n" unless k.match(/[rack,sinatra]/)
    end
    self.request_headers = output

    body_text = request.body.read
    if body_text && body_text.length > 0
      self.request_body = body_text
    else
      self.request_body = ''
    end
    self.request_environment = ENV['TEST_ENV']
    self.request_http_verb = self.request_http_verb.upcase
  end

  #
  # Deletes all rows from the httprequestlogs table
  #
  def clear_request_log
    ActiveRecord::Base.connection.raw_connection.execute('DELETE FROM HTTPREQUESTLOGS')
  end
end




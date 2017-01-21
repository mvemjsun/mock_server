require_relative '../controllers/application_controller'

class MockServerController < ApplicationController

  get '/livelogs' do
    @title = 'Live logs'
    haml :http_request_logs
  end

  get '/livelogs/detail/:id' do
    @title = 'HTTP Request details'
    request_details = Httprequestlog.get_log_details(params['id'])
    haml :request_log_details, locals: {request_details: request_details}
  end

end
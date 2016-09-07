require_relative '../controllers/application_controller'

class MockServerController < ApplicationController

  #
  # Gets the mock record details for the client. Does not return mock body to optimize response.
  #
  get '/api/:id' do
    mockData = Mockdata.select(:id,
                               :mock_name,
                               :mock_request_url,
                               :mock_http_verb,
                               :mock_data_response_headers,
                               :mock_state,:mock_environment,
                               :mock_content_type,
                               :mock_served_times).where(id: params[:id])
    if (params[:id].to_i.is_a? Fixnum) && (mockData.any?)
      content_type 'application/json'
      status 200
      return mockData.first.to_json
    else
      content_type 'text/plain'
      status 404
      body 'Not Found'
    end
  end

  #
  # Activate a mock URL using id
  #
  post '/api/activate/:id' do
    response = activate_mock_with_id
    status = response[:status]
    body = response[:body]
  end

  #
  # Deactivate a mock URL using id
  #
  post '/api/deactivate/:id' do
    response = deactivate_mock_with_id
    status = response[:status]
    body = response[:body]
  end

  #
  # Activate replace data
  #

  post '/api/replace_data/activate/:id' do
    status = Replacedata.new.activate_replace_mock_data(params['id'])
    content_type 'text/plain'
    if status
      status = 200
      body = 'Activated successfully'
    else
      status = 404
      body = 'Could not activate'
    end
  end

  post '/api/reset' do
    Mockdata.new.reset_served_counts
    content_type 'text/plain'
    status = 200
    body = 'Served counts reset.'
  end

  post '/api/reset/requestlog' do
    Httprequestlog.new.clear_request_log
    content_type 'text/plain'
    status = 200
    body = 'Request log has been cleared.'
  end


end
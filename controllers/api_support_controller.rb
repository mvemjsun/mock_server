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


end
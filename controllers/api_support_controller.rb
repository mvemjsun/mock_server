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
                               :mock_state, :mock_environment,
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
      status 200
      body = 'Activated successfully'
    else
      status 404
      body = 'Could not activate'
    end
  end

  #
  # Deactivate mock replace data
  #
  post '/api/replace_data/deactivate/:id' do
    status = Replacedata.new.deactivate_replace_mock_data(params['id'])
    content_type 'text/plain'
    if status
      status 200
      body = 'De-activated successfully'
    else
      status 404
      body = 'Could not De-activate'
    end
  end

  post '/api/reset' do
    Mockdata.new.reset_served_counts
    content_type 'text/plain'
    status 200
    body = 'Served counts reset.'
  end

  post '/api/reset/requestlog' do
    Httprequestlog.clear_request_log
    content_type 'text/plain'
    status 200
    body = 'Request log has been cleared.'
  end

  #
  # Get request logs for a given time range
  # the rage is specified in the `from` and `to` query parameters
  # @example /mock/api/requestlog/range?from=2016-09-26%2016:31:00&to=2016-09-26%2016:32:11
  #
  get '/api/requestlog/range' do
    if (params.has_key?('from') && params.has_key?('to'))
      if (valid_datetime_string?(params['from']) && valid_datetime_string?(params['to']))
        if params.has_key? 'matching'
          matching_string = params['matching']
        else
          matching_string = nil
        end
        response = Httprequestlog.get_request_log(start_datetime=params['from'],
                                                  end_datetime=params['to'],
                                                  matching=matching_string)
        content_type 'text/json'
        if JSON.parse(response).first.has_key? 'message'
          status 404
        else
          status 200
        end
        body = response
      else
        content_type 'text/json'
        status 400
        body = '{"message" : "Invalid dates supplied."}'
      end
    else
      content_type 'text/json'
      status 400
      body = '{"message" : "Both from and to date need to be supplied as query parameters."}'
    end

  end

  #
  # Get recent request logs
  #
  get '/api/requestlog/recent' do
    response = Httprequestlog.get_request_log
    content_type 'text/json'
    status 200
    body = response
  end

  #
  # Update the replace data replacing string
  #
  post '/api/update/replacedata' do
    if (params.has_key?('string') && params.has_key?('with'))
      Replacedata.update_replace_string(params['string'],params['with'])
      content_type 'text/plain'
      status 200
      body = 'Replace data updated'
    else
      content_type 'text/plain'
      status 402
      body = 'Please supply query parameters ?string=xxx&with=yyy'
    end
  end


end
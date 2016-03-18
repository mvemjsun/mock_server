class MockServerController < ApplicationController

  get '/search' do
    @title = 'Search'
    haml :search_mock
  end

  get '/search/misses' do
    @title = 'Missed requests'
    missed_data = MissedRequest.order('created_at DESC').all
    haml :missed_requests, locals: {missed_data: missed_data}
  end

  get '/search/result' do
    @title = 'Search Result(s)'
    search_data = search_mock_data({mock_name: params[:search_mock_name].upcase})

    haml :search_results, locals: {search_data: search_data}
  end

  get "/update/:id" do
    @title = "Mock Update"
    mock_data = Mockdata.where(id: params[:id].to_i)
    haml :create_mock_request, locals: {mock_data: mock_data.first}
  end

  delete "/delete/:id" do
    @title = "Mock Deleted"
    mock_data = Mockdata.where(id: params[:id].to_i)
    data = mock_data.first
    if mock_data.any?
      mock_data.destroy(params[:id].to_i)
      haml :mock_deleted_ack, locals: {message: "Record deleted successfully", success: true}
    else
      haml :mock_deleted_ack, locals: {message: "Not Found", success: false}
    end
  end

  get "/create" do
    @title = "Create mock response"
    haml :create_mock_request, locals: {mock_data: nil}
  end

  post "/create" do
    @title = "Create mock - Acknowledge"

    errors = nil
    begin

      url_path = URI::parse(params[:mock_request_url]).path.sub(/^\//, '')
      url_query = URI::parse(params[:mock_request_url]).query

      if url_query
        url = url_path + '?' + url_query
      else
        url = url_path
      end
      mockdata = Mockdata.where(mock_name: params[:mock_name].upcase,
                                mock_request_url: url,
                                mock_environment: params[:mock_environment] #,
      # mock_state: params[:mock_state].nil? ? false : true
      )

      mockdata_exist = Mockdata.where(
                                mock_request_url: url,
                                mock_environment: params[:mock_environment] ,
                                mock_state: params[:mock_state].nil? ? false : true
      )

      if mockdata.any?
        # errors = "Found record"

        data = mockdata.first
        data.mock_name= params[:mock_name]
        data.mock_request_url= url
        data.mock_state= params[:mock_state].nil? ? false : true
        data.mock_http_status= params[:mock_http_status]
        data.mock_data_response_headers= params[:mock_data_response_headers]
        data.mock_data_response= params[:mock_data_response]
        data.mock_environment= params[:mock_environment]
        data.mock_content_type= params[:mock_content_type]
        # raise ActiveRecord::RecordNotUnique, "Record not unique"
        # errors = true
        data.save!
        state = :updated
      else
        # errors = "Not Found record"
        data = Mockdata.new
        data.mock_name= params[:mock_name]
        data.mock_request_url= url
        data.mock_state= params[:mock_state].nil? ? false : true
        data.mock_http_status= params[:mock_http_status]
        data.mock_data_response_headers= params[:mock_data_response_headers]
        data.mock_data_response= params[:mock_data_response]
        data.mock_environment= params[:mock_environment]
        data.mock_content_type= params[:mock_content_type]
        data.mock_served_times= 0
        data.save!
        state = :created
      end
    rescue ActiveRecord::RecordNotUnique => errors
      session[:errors] = ["Only one URL can be active at a time. URL with name '#{(mockdata_exist.first.mock_name).upcase}' is already active."]
    rescue ActiveRecord::ActiveRecordError => errors
      # session[:errors] = errors.record.errors
      session[:errors] = [errors.message]
    end

    #
    # Validate JSON
    #
    json_state = :valid
    if params[:mock_content_type] == 'application/json;charset=UTF-8'
      if valid_json?(params[:mock_data_response])
        json_state = :valid
      else
        json_state = :invalid
      end
    end

    if errors
      messages = errors
      # haml :create_mock_response, locals: {messages: messages}
      haml :create_mock_request, locals: {mock_data: data}
    else
      haml :create_mock_response, locals: {messages: false,
                                           mock_name: params[:mock_name],
                                           mock_request_url: url,
                                           mock_environment: params[:mock_environment],
                                           mock_content_type: params[:mock_content_type],
                                           mock_data_response_headers: params[:mock_data_response_headers],
                                           mock_http_status: params[:mock_http_status],
                                           mock_state: params[:mock_state],
                                           mock_record_state: state,
                                           json_state: json_state
      }
    end

  end

  #
  # Clone the mock data if URL is reachable, supports only GET requests
  # will preset the mock body and headers.Build the 'mockdata' object with all columns if data found
  #
  get '/clone' do
    @title = 'Clone data'
    mock_data = {}
    if params[:mock_request_url].length > 0
      begin
        response = HTTParty.get(params[:mock_request_url])
      rescue => e
        # Ignore fatal URL responses
      end
      if (response) &&
          (response.code.to_s.match(/^[1,2,3,404]/))
        mock_data = extract_clone_response(response,
                                           params[:mock_request_url],
                                           params[:mock_name])
        haml :create_mock_request, locals: {mock_data: mock_data}
      else
        haml :create_mock_request, locals: {mock_data: nil}
      end
    else
      haml :create_mock_request, locals: {mock_data: nil}
    end
  end

  get '/clone/batch' do
    @title = 'Clone in batch'
    haml :batch_clone
  end

  post '/clone/batch' do
    @title = 'Clone in batch'
    response = process_batch_clone_request(params)
    bd = case response
           when :updated
             'Updated'
           when :error_updating
             'Error Updating'
           when :created
             'Created'
           when :error_creating
             'Error Creating'
         end
    content_type 'application/text'
    status 200
    body bd
  end


end
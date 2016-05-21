require_relative '../controllers/application_controller'

class MockServerController < ApplicationController

  helpers Sinatra::Cookies
  #
  # Display the mock data search form for the user to enter the part of the mock name
  #
  get '/search' do
    @title = 'Search'
    haml :search_mock
  end

  #
  # Display the missed requests log
  #
  get '/search/misses' do
    @title = 'Missed requests'
    missed_data = MissedRequest.order('created_at DESC').all
    haml :missed_requests, locals: {missed_data: missed_data}
  end

  #
  # Display the search results for a mock name (part)
  #
  get '/search/result' do
    @title = 'Search Result(s)'
    search_data = search_mock_data({mock_name: params[:search_mock_name].upcase,
                                    mock_request_url: params[:search_mock_request_url]})

    haml :search_results, locals: {search_data: search_data}
  end

  #
  # Display the data for an existing mock. The data is retrieved using the mock internal database id. This is transferred
  # from the search results page
  #
  get "/update/:id" do
    @title = "Mock Update"
    mock_data = Mockdata.where(id: params[:id].to_i)
    haml :create_mock_request, locals: {mock_data: mock_data.first}
  end

  #
  # Delete a mock data, not available via a web form or page. Needs to be called via command line.
  #
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

  #
  # TODO Hack to delete a missed row, change to delete
  # Delete a missed request log data
  #
  post "/misses/delete/:id" do
    @title = "Mock misses Deleted"
    missed_data = MissedRequest.where(id: params[:id].to_i)
    data = missed_data.first
    if missed_data.any?
      missed_data.destroy(params[:id].to_i)
      missed_data = MissedRequest.order('created_at DESC').all
      haml :missed_requests, locals: {missed_data: missed_data}
    else
      haml :mock_deleted_ack, locals: {message: "Not Found", success: false}
    end
  end

  #
  # Display the mock create page for a user to create a new mock data for a URL.
  #
  ['/create', '/home'].each do |path|
    get path do
      @title = "Create mock response"
      haml :create_mock_request, locals: {mock_data: nil}
    end
  end

  #
  # Create the mock data when a form the create form is submit. Some validations are applied directly via the model for
  # mandatory fields. Only one URL of the same time can be active at the same time for a test environment.
  #
  post "/create" do
    @title = "Create mock - Acknowledge"

    errors = nil
    begin

      url_path = URI::parse(params[:mock_request_url].strip).path.sub(/^\//, '')
      url_query = URI::parse(params[:mock_request_url].strip).query

      if url_query
        url = url_path + '?' + url_query
      else
        url = url_path
      end

      if params[:id].length == 0
        # If New record being attempted to be created and a duplicate name/url/env is found
        mockdata = Mockdata.where(mock_name: params[:mock_name].upcase,
                                  mock_request_url: url,
                                  mock_http_verb: params[:mock_http_verb],
                                  mock_environment: params[:mock_environment]
        )
        if mockdata.any?
          data = mockdata.first
          # Set id to nil so that the request is treated as a new record
          data.id = nil
          raise DuplicateNameAndURL, "Mock name and URL already exist with the name #{data.mock_name}. Search and edit or provide a different name."
          errors = true
        end
      else
        mockdata = Mockdata.where(id: params[:id].to_i)
      end

      mockdata_exist = Mockdata.where(
          mock_request_url: url,
          mock_environment: params[:mock_environment],
          mock_state: params[:mock_state].nil? ? false : true
      )

      if mockdata.any?
        # errors = "Found record"

        data = mockdata.first
        data.mock_name= params[:mock_name]
        data.mock_request_url= url
        data.mock_http_verb= params[:mock_http_verb]
        data.mock_state= params[:mock_state].nil? ? false : true
        data.mock_http_status= params[:mock_http_status]
        data.mock_data_response_headers= params[:mock_data_response_headers]
        data.mock_data_response= params[:mock_data_response]
        data.mock_environment= params[:mock_environment]
        data.mock_content_type= params[:mock_content_type]
        data.mock_cookie = params[:mock_cookie]
        data.save!
        state = :updated
      else
        # errors = "Not Found record"
        data = Mockdata.new
        data.mock_name= params[:mock_name]
        data.mock_request_url= url
        data.mock_http_verb= params[:mock_http_verb]
        data.mock_state= params[:mock_state].nil? ? false : true
        data.mock_http_status= params[:mock_http_status]
        data.mock_data_response_headers= params[:mock_data_response_headers]
        data.mock_data_response= params[:mock_data_response]
        data.mock_environment= params[:mock_environment]
        data.mock_content_type= params[:mock_content_type]
        data.mock_cookie = params[:mock_cookie]
        data.mock_served_times= 0
        data.save!
        state = :created
      end
      # Refresh cache
      if url.index('*')
        $wild_routes = WildRoutes.get_wild_routes_if_any
        p 'Cache refreshed'
        p $wild_routes
      end
    rescue DuplicateNameAndURL => errors
      session[:errors] = [errors.message]
    rescue ActiveRecord::RecordNotUnique => errors
      session[:errors] = ["Only one URL can be active at a time. This URL is already ACTIVE with the name '#{(mockdata_exist.first.mock_name).upcase}' ."]
    rescue ActiveRecord::ActiveRecordError => errors
      session[:errors] = [errors.message]
    end

    #
    # Validate JSON
    #
    json_state = :valid
    if (data.mock_http_status.match(/^[^4-5]/)) &&
        (params[:mock_content_type] == 'application/json;charset=UTF-8')
      if valid_json?(params[:mock_data_response])
        json_state = :valid
      else
        json_state = :invalid
      end
    end

    if errors
      messages = errors
      haml :create_mock_request, locals: {mock_data: data}
    else
      haml :create_mock_response, locals: {messages: false,
                                           mock_name: params[:mock_name],
                                           mock_request_url: url,
                                           mock_http_verb: params[:mock_http_verb],
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
  # Clone the mock data if URL is reachable already, supports only GET requests
  # will preset the mock body and headers.Build the 'mockdata' object with all columns if data found
  #
  get '/clone' do
    @title = 'Clone data'
    mock_data = {}
    msg = nil
    if params[:mock_request_url].length > 0
      begin
        response = HTTParty.get(params[:mock_request_url])
      rescue => e
        # Ignore fatal URL responses
        msg = e.message
      end
      if (response) &&
          (response.code.to_s.match(/^[1,2,3,404]/))
        mock_data = extract_clone_response(response,
                                           params[:mock_request_url],
                                           params[:mock_name])
        haml :create_mock_request, locals: {mock_data: mock_data}
      else
        mock_data = ClonedData.new
        mock_data.mock_data_response = msg if msg
        mock_data.mock_request_url = params[:mock_request_url]
        haml :create_mock_request, locals: {mock_data: mock_data}
      end
    else
      mock_data = Mockdata.new
      mock_data.mock_data_response = msg if msg
      mock_data.mock_request_url = params[:mock_request_url] if params[:mock_request_url].length > 0
      haml :create_mock_request, locals: {mock_data: mock_data}
    end
  end

  #
  # Display the form to create multiple mocks in one go, Supports only URLs that are GET type.
  #
  get '/clone/batch' do
    @title = 'Clone in batch'
    haml :batch_clone
  end

  #
  # Process the URLs to be cloned into the mock database. These can then be searched by name and modified.
  #
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

  #
  # Search any available replace data.
  #
  get '/replace/search' do
    @title = 'Maintain search strings'
    haml :search_replace, locals: {search_data: nil, search_message: nil}
  end

  get '/replace/search/results' do
    @title = 'Intelli replace - search results'
    search_data = search_replace_data({replace_name: params[:replace_name].upcase})

    search_message = 'No data found' unless search_data
    haml :search_replace, locals: {search_data: search_data, search_message: search_message}
  end

  get '/replace/create_update' do
    @title = 'Create update replace data'
    haml :create_update_replace_data, locals: {replace_data: nil}
  end

  #
  # Create/Update the replace data. Replace data is used to silently replace mock responses with the replace strings that
  # we supply when creating the replace data.
  #
  post '/replace/create_update' do
    @title = 'Updated replace data'

    if params[:id].length == 0
      # Create
      response = create_update_replace_data({create: true})
      state = :created
    else
      # Update
      response = create_update_replace_data({create: false})
      state = :updated
    end

    if response[:error]
      session[:errors] = [response[:message]]
      haml :create_update_replace_data, locals: {replace_data: response[:replace_data]}
    else
      haml :create_update_replace_data_ack, locals: {replace_data: response[:replace_data], replace_record_state: state, messages: nil}
    end
  end

  #
  # Display replace data for update. The replace data id is the internal database id passed from the search page.
  #
  get '/replace/update/:id' do
    @title = "Replace string Update"
    replace_data = Replacedata.where(id: params[:id].to_i)
    if replace_data.any?
      haml :create_update_replace_data, locals: {replace_data: replace_data.first}
    else
      session[:errors] = [response[:message]]
      redirect '/mock/replace/search'
    end

  end


end
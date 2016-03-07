class MockServerController < ApplicationController

  get '/search' do
    @title = 'Search'
    haml :search_mock
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

  get "/create" do
    @title = "Create mock response"
    haml :create_mock_request
  end

  post "/create" do
    @title = "Create mock - Acknowledge"

    errors = nil
    begin

      url = params[:mock_request_url].sub(/^\//, '')
      mockdata = Mockdata.where(mock_name: params[:mock_name],
                                mock_request_url: url,
                                mock_environment: params[:mock_environment],
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
        data.save!
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
        data.save!
      end
    rescue ActiveRecord::ActiveRecordError => errors
    end


    if errors
      messages = errors
      haml :create_mock_response, locals: {messages: messages}
    else
      haml :create_mock_response, locals: {messages: false,
                                           mock_name: params[:mock_name],
                                           mock_request_url: url,
                                           mock_environment: params[:mock_environment],
                                           mock_state: params[:mock_state]
                                          }
    end

  end
end
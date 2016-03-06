
class MockServerController < ApplicationController

  # before do
  #   p "Trying to connect to #{File.expand_path('./config', 'database.yml')}"
  #   db = YAML.load_file(File.expand_path('./config', 'database.yml'))['development']
  #   ActiveRecord::Base.establish_connection db
  # end

  get "/create" do
    @title = "Create mock response"
    haml :create_mock_request
  end

  post "/create" do
    @title = "Create mock - Acknowledge"
    mockdata = Mockdata.new
    p params[:mock_name]
    mockdata.mock_name= params[:mock_name]
    mockdata.mock_request_url= params[:mock_request_url]
    if params[:mock_state]
      mockdata.mock_state= true
    else
      mockdata.mock_state= false
    end
    mockdata.mock_http_status= params[:mock_http_status]
    mockdata.mock_data_response_headers= params[:mock_data_response_headers]
    mockdata.mock_data_response= params[:mock_data_response]
    mockdata.mock_environment= params[:mock_environment]
    mockdata.mock_content_type= params[:mock_content_type]

    mockdata.save!

    if mockdata.errors.messages
      messages = mockdata.errors.messages
      haml :create_mock_response, locals: {messages: messages}
    else
      haml :create_mock_response
    end

  end
end
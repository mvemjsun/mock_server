
module ApplicationHelper

  def h(text)
    Rack::Utils.escape_html(text)
  end
  #
  # The main processing function that server the mock responses
  # Read the model for the given url in a test environment and serve it as a HTTP response
  # as specified in the mock with correct headers and status code.
  #
  # @param [String] url, The URL that is being mocked.
  # @return [Hash] response hash with keys :mock_http_status, :mock_data_response_headers, :mock_data_response [,:error]
  #

  def process_url(url, env=ENV['TEST_ENV'])
    p url
    p env
    return_data={}
    data = Mockdata.where(mock_request_url: url, mock_environment: env)
    if data.any?
      row = data.first
      return_data[:mock_http_status] = row[:mock_http_status]
      return_data[:mock_data_response] = row[:mock_data_response]
      return_data[:mock_data_response_headers] = row[:mock_data_response_headers]
    else
      return_data[:error] = "Not Found"
    end
    return return_data
  end

end

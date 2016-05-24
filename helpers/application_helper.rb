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

  def process_url(url, method='GET', env=ENV['TEST_ENV'])
    return_data={}
    data = Mockdata.where(mock_request_url: url, mock_http_verb: method, mock_environment: env, mock_state: true)
    if data.any?
      return_data = get_mock_data(data.first)
    else
      wild_route_data = try_wildcard_route_mock_data(method, env)
      if wild_route_data
        return_data = wild_route_data
      else
        return_data[:error] = 'Not Found' unless return_data
      end
    end
    return return_data
  end

  def intelligent_response_replace(response_to_be_replaced)
    replace_data = Replacedata.where(mock_environment: ENV['TEST_ENV'], replace_state: true)
    replaced_response = response_to_be_replaced.dup
    replace_data.each do |row|
      # replaced_response ||= response_to_be_replaced.dup
      if row.is_regexp
        re = Regexp.new(row.replaced_string)
        replaced_response.gsub!(re, row.replacing_string)
      else
        replaced_response.gsub!(row.replaced_string, row.replacing_string)
      end
    end
    return replaced_response
  end

  #
  # Search for mock data either by name OR URL. Options key name should match the column name
  # @param [Hash] options with key :mock_name or :mock_request_url
  #
  def search_mock_data(options)
    # data = Mockdata.where(mock_name: options[:mock_name])
    if options[:mock_request_url].length == 0
      data = Mockdata.where("mock_name LIKE ?", "%#{options[:mock_name]}%")
    else
      data = Mockdata.where("mock_request_url LIKE ?", "%#{options[:mock_request_url]}%")
    end

    if data.any?
      return data
    else
      return nil
    end
  end

  #
  # Search the replace data table and return results
  #
  def search_replace_data(options)
    data = Replacedata.where("replace_name LIKE ?", "%#{options[:replace_name]}%")
    if data.any?
      return data
    else
      return nil
    end
  end

  #
  # Search the rubyscript table and return results
  #
  def search_script_data(options)
    data = Rubyscript.where("script_name LIKE ?", "%#{options[:script_name]}%")
    if data.any?
      return data
    else
      return nil
    end
  end

  #
  #
  #
  def flash_messages
    session[:errors]
  end

  #
  # Build headers hash
  # @param [String] the headers string
  # @return [Hash] The headers hash
  #

  def build_headers(headers_string)
    headers_hash = {}
    headers_array = headers_string.split(/\r\n/)
    headers_array.each do |header_row|
      k, v = header_row.split(ENV['HEADER_DELIMITER'])
      headers_hash[k] = v
    end
    return headers_hash
  end

  #
  # Extract the HTTParty response for cloning the mock data set response hash to include all table columns.
  # The clone will only provide the body and the headers, rest set to nil. Assumes a valid HTTP response with success
  #
  def extract_clone_response(response, url, mock_name)

    mock_data = ClonedData.new
    mock_data.mock_name = mock_name
    mock_data.mock_http_status = response.code
    mock_data.mock_state = true
    mock_data.mock_environment = ENV['TEST_ENV']
    mock_data.mock_content_type = ENV['DEFAULT_CONTENT_TYPE']
    mock_data.mock_request_url = url
    hdr_string = 'X-Mock'+ENV['HEADER_DELIMITER']+'True'
    hdr_string = hdr_string + "\r\n" + 'Cache-Control' + ENV['HEADER_DELIMITER'] + 'max-age=0, no-cache'

    response.headers.each do |header, hdr_value|
      hdr_string = hdr_string + "\r\n" + header + ENV['HEADER_DELIMITER'] + hdr_value
    end
    mock_data.mock_data_response_headers = hdr_string
    mock_data.mock_data_response = response.body
    mock_data.id = nil
    return mock_data
  end

  #
  # JSON Validator
  #
  def valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end

  #
  # When part of a batch clone request arrives it supplies the Mock Name, URL and Test environment
  # Check of the Mock name, URL, Environment has an active record, if so then update it else create
  # a new record in the mocking database
  # @params [Hash] params hash with keys :name, :url & :mock_request_environment
  # @return [Symbol] state with values :created, :error_creating, :updated, :error_updating
  #
  def process_batch_clone_request(params)

    url_path = URI::parse(params[:url]).path.sub(/^\//, '')
    url_query = URI::parse(params[:url]).query

    if url_query
      url = url_path + '?' + url_query
    else
      url = url_path
    end

    state = :created
    mockdata = Mockdata.where(mock_request_url: url,
                              mock_name: params[:name].upcase,
                              mock_environment: params[:mock_test_environment])
    if mockdata.any?
      # errors = "Found record", then get new data to clone
      begin
        response = HTTParty.get(params[:url])
      rescue => e
        # Ignore fatal URL responses
      end
      if (response) &&
          (response.code.to_s.match(/^[1,2,3]/))
        data = mockdata.first
        data.mock_name= params[:name]
        data.mock_request_url= url
        data.mock_http_status= response.code
        data.mock_data_response_headers= extract_clone_response(response, params[:url], params[:name]).mock_data_response_headers
        data.mock_data_response= response.body
        data.mock_environment= params[:mock_test_environment]
        data.mock_content_type= 'application/json;charset=UTF8'
        data.mock_http_verb='GET'
        data.save!
        state = :updated

      else
        state = :error_updating
      end
    else
      # New record need to be created
      begin
        response = HTTParty.get(params[:url])
      rescue => e
        # Ignore fatal URL responses
      end

      begin
        if (response) &&
            (response.code.to_s.match(/^[1,2,3]/))
          data = Mockdata.new
          data.mock_name= params[:name]
          data.mock_request_url= url
          data.mock_http_status= response.code
          data.mock_data_response_headers= extract_clone_response(response, params[:url], params[:name]).mock_data_response_headers
          data.mock_data_response= response.body
          data.mock_environment= params[:mock_test_environment]
          data.mock_content_type= 'application/json;charset=UTF8'
          data.mock_state = true
          data.mock_http_verb='GET'
          data.save!
          state = :created
        else
          state = :error_creating
        end
      rescue => e
        p e.message
        state = :error_creating
      end
    end
    return state
  end

  #
  # Log the missed requests that could not be served
  #
  def log_missed_requests(request_object)
    missed_request = MissedRequest.new

    url_path = URI::parse(request_object.url).path.sub(/^\//, '')
    url_query = URI::parse(request_object.url).query

    if url_query
      url = url_path + '?' + url_query
    else
      url = url_path
    end
    missed_request.url = (url.nil? || url.size == 0) ? '/' : url
    missed_request.mock_environment = ENV['TEST_ENV']
    missed_request.mock_http_verb = request_object.request_method
    missed_request.save!
  end

  #
  # Create or update the replace data strings and their replacements.
  # @params [Hash] keys :create with value true or false
  # @return [Hash] keys :error, :message, :replace_data
  #
  def create_update_replace_data(options)
    error = false
    return_data = {}
    if options[:create]
      data = Replacedata.where(replaced_string: params[:replaced_string],
                               mock_environment: params[:mock_environment],
                               replace_state: true)
      begin
        replaceData = Replacedata.new
        replaceData.replace_name = params[:replace_name].upcase
        replaceData.replaced_string = params[:replaced_string]
        replaceData.replacing_string = params[:replacing_string]
        replaceData.replace_state = params[:replace_state].nil? ? false : true
        replaceData.is_regexp = params[:is_regexp].nil? ? false : true
        replaceData.mock_environment = params[:mock_environment]
        replaceData.save!
      rescue ActiveRecord::RecordNotUnique => errors
        message = ["This replace is already ACTIVE with name '#{(data.first.replace_name).upcase}'."]
        error = true
      rescue ActiveRecord::ActiveRecordError => errors
        error = true
        message = [errors.message]
      end
    else
      data = Replacedata.where(id: params[:id])
      if data.any?
        replaceData = data.first
        replaceData.replace_name = params[:replace_name].upcase
        replaceData.replaced_string = params[:replaced_string]
        replaceData.replacing_string = params[:replacing_string]
        replaceData.replace_state = params[:replace_state].nil? ? false : true
        replaceData.is_regexp = params[:is_regexp].nil? ? false : true
        replaceData.mock_environment = params[:mock_environment]
        replaceData.save!
      else
        error = true
        message = "Replace data with id #{params[:id]} not found."
      end

    end
    return_data[:error] = error
    return_data[:message] = message
    return_data[:replace_data] = replaceData
    return return_data
  end

  def process_http_verb
    url = request.fullpath.sub!(/^\//, '')
    @mock_response = process_url(url, request.request_method, ENV['TEST_ENV'])

    if ENV['LATENCY']
      sleep ENV['LATENCY'].to_i unless ENV['LATENCY'].to_i == 0
    end

    if  @mock_response.has_key? :error
      log_missed_requests(request)
      content_type 'application/text'
      status 404
      body 'Not Found'
    else
      status_code =  @mock_response[:mock_http_status].to_i
      status status_code
      content_type @mock_response[:mock_content_type]
      headers @mock_response[:mock_data_response_headers]
      cookies.merge! @mock_response[:mock_cookie]

      if @mock_response[:mock_content_type].match(/^image\//)
        send_file File.join('public/upload/', @mock_response[:image_file])
      else
        body @mock_response[:mock_data_response]
      end
    end
  end

  #---------
  private
  #---------

  #
  # If there is no exact route match then try to see if there is a wildcard route match and return its data
  # @return [Hash] response hash with keys :mock_http_status, :mock_data_response_headers, :mock_data_response [,:error => 'Not Found']
  #
  def try_wildcard_route_mock_data(method,env)
    wild_route_urls = $wild_routes.keys
    url_path = URI::parse(request.url).path.sub(/^\//, '')
    url_query = URI::parse(request.url).query
    if url_query
      url = url_path + '?' + url_query
    else
      url = url_path
    end
    matched_route = wild_route_urls.find { |route| Regexp.new(route).match url }
    if matched_route
      route_id = $wild_routes[matched_route]
      data = Mockdata.where(id: route_id,
                            mock_environment: env,
                            mock_state: true,
                            mock_http_verb: method )
      return get_mock_data(data.first)
    else
      return {:error => 'Not Found'}
    end
  end

  #
  # Refactored into a common routine for returning the mock data hash
  # @param [ActiveRecordData] row with mock data from the table
  # @return [Hash] response hash with keys :mock_http_status, :mock_data_response_headers, :mock_data_response, :id [,:error]
  #
  def get_mock_data(row)
    return_data = {}
    return_data[:mock_http_status] = row[:mock_http_status]
    response_body = row[:mock_data_response]

    if row[:mock_content_type].match(/^image\//)
      return_data[:image_file] = url.split('/').last
      return_data[:mock_data_response] = nil
    else
      if ENV['REPLACE']
        return_data[:mock_data_response] = intelligent_response_replace(response_body)
      else
        return_data[:mock_data_response] = row[:mock_data_response]
      end
    end
    return_data[:mock_cookie] = extract_cookies(row[:mock_cookie])
    return_data[:mock_data_response_headers] = build_headers row[:mock_data_response_headers]

    return_data[:mock_content_type] = row[:mock_content_type]
    return_data[:id] = row[:id]
    row.mock_served_times = row.mock_served_times + 1
    row.save!
    return return_data
  end

  #
  # Extract the cookie name and value from the data, cookie name is followed by a space character followed by the
  # value of the cookie
  # @param [String] cookie_data
  # @return [Hash] Cookie info hash keyed by cookie name
  #
  def extract_cookies(mock_cookie)
    cookies = {}
    if mock_cookie
      cookie_data = mock_cookie.split(/\r\n/)
      cookie_data.each do |cookie_line|
        trimmed_line = cookie_line.gsub(/^\s*/, '')
        if trimmed_line.size > 0
          first_sp_index = trimmed_line.index("\s")
          if first_sp_index
            cookie_name = trimmed_line[0..first_sp_index-1]
            cookie_value = trimmed_line[first_sp_index..trimmed_line.length]
            cookies[cookie_name] = cookie_value
          else
            # Just name no value
            cookie_name = trimmed_line.chomp
            cookies[cookie_name] = ''
          end
        end
      end
    end
    return cookies
  end

end

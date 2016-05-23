module ApplicationHelper

  def process_before_script
    if has_before_script?

    end
  end

  def process_after_script
    if has_after_script?

    end
  end

  def has_before_script?
    row = get_current_request_db_row
    if row && row[:has_before_script]
      p "Request has before script - #{row[:before_script_name]}"
      return true
    end
  end

  def has_after_script?
    row = get_current_request_db_row
    if row && row[:has_after_script]
      p "Request has before script - #{row[:after_script_name]}"
      return true
    end
  end

  def get_current_request_db_row
    # if !defined? @current_request_db_data
      @current_request_db_data = nil
      url = request.fullpath.sub!(/^\//, '')
      query = Mockdata.where(mock_request_url: url,
                             mock_http_verb: request.request_method,
                             mock_environment: ENV['TEST_ENV'],
                             mock_state: true)

      if query.any?
        @current_request_db_data = query.first
      else
        wild_try = try_wildcard_route_mock_data((request.request_method).upcase,ENV['TEST_ENV'])
        if wild_try.has_key? :error
        else
          @current_request_db_data = Mockdata.where(id: wild_try[:id]).first
        end
      end
    # else
    #   p "@current_request_db_data already set - #{@current_request_db_data}"
    # end
    return @current_request_db_data
  end

end
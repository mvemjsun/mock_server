module ApplicationHelper

  def process_before_script
    if has_before_script?
      process_script :before
    end
  end

  def process_after_script
    if has_after_script?
      process_script :after
    end
  end

  def has_before_script?
    row = get_current_request_db_row
    if row && row[:has_before_script]
      return true
    end
  end

  def has_after_script?
    row = get_current_request_db_row
    if row && row[:has_after_script]
      return true
    end
  end

  #
  # Get the current requests mock data from the database.
  # @param [None]
  # @return [Activerecord::Record]
  #
  def get_current_request_db_row
    if !defined? @current_request_db_data
      @current_request_db_data = nil
      url = URI.parse(request.fullpath).path.sub!(/^\//, '')
      query = Mockdata.where(mock_request_url: url,
                             mock_http_verb: request.request_method,
                             mock_environment: ENV['TEST_ENV'],
                             mock_state: true)

      if query.any?
        @current_request_db_data = query.first
      else
        wild_try = try_wildcard_route_mock_data((request.request_method).upcase, ENV['TEST_ENV'])
        if wild_try.has_key? :error
        else
          @current_request_db_data = Mockdata.where(id: wild_try[:id]).first
        end
      end
    end
    return @current_request_db_data
  end

  #
  # Evaluate the before and after scripts
  # @param [Symbol] :before or :after
  # The scripts are evaluated using a simple ruby eval so its upto the user to know the risks
  #
  def process_script(type)
    begin
      case type
        when :before
          scripts = @current_request_db_data[:before_script_name].split(/,/)
          scripts.each do |script_name|
            row = Rubyscript.where(script_name: script_name.strip).first
            eval(row.script_body) unless row.blank?
            $logger.debug "Processed BEFORE script #{script_name}"
          end
        when :after
          scripts = @current_request_db_data[:after_script_name].split(/,/)
          scripts.each do |script_name|
            row = Rubyscript.where(script_name: script_name.strip).first
            eval(row.script_body) unless row.blank?
            $logger.debug "Processed AFTER #{script_name}"
          end
      end
    rescue => error
      $logger.error '------ SCRIPT ERROR ----------'
      $logger.error error.message
      $logger.error '------------------------------'

    end
  end

end

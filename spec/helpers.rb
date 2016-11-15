module TestHelper

  extend Capybara::DSL

  def self.create_test_mock(data)
    fill_in('mock_name', with: data[:mock_request_name])
    fill_in('mock_http_status', with: data[:mock_http_status])
    check('chk_mock_state') if (data[:mock_enabled])

    fill_in('Request URL To mock', with: data[:mock_request_url])
    select(data[:mock_http_verb], :from => 'sl_mock_http_verb')
    select(data[:mock_test_environment], :from => 'sl_mock_environment')
    select(data[:mock_content_type], :from => 'id_mock_content_type')
    fill_in('json_body', with: data[:mock_http_body])
  end

  def self.set_advanced_options(data)

  end

  def self.submit_form_to_create_update_mock_data
    click_button('Create/Update Mock Data')
  end

  def self.mockData(options={})
    return {mock_request_name: 'Test Mock 2',
            mock_http_status: 200,
            mock_enabled: true,
            mock_request_url: 'a/test/url',
            mock_http_verb: 'GET',
            mock_test_environment: 'production',
            mock_content_type: 'text/plain',
            mock_http_body: 'mock body'
    }.merge! options
  end

  def self.insert_mock_row_into_db(options={})
    data = {
        mock_name: 'Test mock 1',
        mock_http_status: 200,
        mock_request_url: 'a/test/url',
        mock_http_verb: 'GET',
        mock_data_response_headers: 'x:==:y',
        mock_state: true,
        mock_environment: 'production',
        mock_content_type: 'text/plain',
        mock_data_response: 'test',
        mock_served_times: 0,
        profile_name: ''
    }
    data.merge! options
    Mockdata.create(data)
  end
end
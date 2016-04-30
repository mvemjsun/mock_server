module ApplicationHelper

  #
  # Activate a mock URL using the id passed in the params
  #
  def activate_mock_with_id
    if params.has_key? 'id'
      mockData = Mockdata.where(id: params['id'])
      if mockData.any?
        data_row = mockData.first
        mock_url = data_row.mock_request_url
        mock_env = data_row.mock_environment
        mock_state = data_row.mock_state

        if !mock_state
          Mockdata.transaction do
            current_active_mock = Mockdata.where(mock_request_url: mock_url, mock_environment: mock_env, mock_state: true)
            new_active_mock = Mockdata.where(id: params['id'])
            current_active_mock.first.mock_state = false unless current_active_mock.blank?
            new_active_mock.first.mock_state = true
            current_active_mock.first.save unless current_active_mock.blank?
            new_active_mock.first.save
          end
        end
        return {status_code: 200, body: 'Activated successfully.'}
      else
        return {status_code: 404, body: 'Not Found'}
      end
    end
  end

  #
  # Deactivate a mock URL using the id passed in the params
  #
  def deactivate_mock_with_id
    if params.has_key? 'id'
      mockData = Mockdata.where(id: params['id'])
      if mockData.any?
        mockData.first.mock_state = false
        mockData.first.save
        return {status_code: 200, body: 'Deactivated successfully.'}
      end
    else
      return {status_code: 404, body: 'Not Found'}
    end
  end

end
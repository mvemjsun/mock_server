module ApplicationHelper

  #
  # Activate a mock URL using the id passed in the params
  #
  def activate_mock_with_id
    if params.has_key? 'id'
      if Mockdata.new.activate_mock_data(params['id'])
        return {status_code: 200, body: 'Activated successfully.'}
      else
        return {status_code: 404, body: 'Not Found.'}
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
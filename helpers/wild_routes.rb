class WildRoutes
  #
  # Reads the mock_data table and returns any routes that have the .* wildcard in it, keyed by the route url and
  # value is the internal id
  # @param None
  # @return [Hash] Key value of route url and its Id
  #
  def self.get_wild_routes_if_any
    return_data = {}
    data = Mockdata.select('mock_request_url, id').where("mock_state = 't' and mock_request_url LIKE ?", "%*%")
    return return_data if data.blank?

    data.each do |data_row|
      return_data[data_row.mock_request_url] = data_row.id
    end
    return return_data
  end
end
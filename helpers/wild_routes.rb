class WildRoutes
  #
  # Reads the mock_data table and returns any routes that have the .* wildcard in it, keyed by the route url and
  # value is the internal id
  # @param None
  # @return [Hash] Key value (prefixed with the http verb) of route url and its id
  # @example return data {"POST:==:vod/(.*)/heartbeat"=>160,"PUT:==:watchlist/(.*)"=>195, "DELETE:==:watchlist/.*"=>196}
  #
  def self.get_wild_routes_if_any
    return_data = {}
    data = Mockdata.select('mock_request_url, id','mock_http_verb').where("mock_state = 't' and mock_request_url LIKE ?", "%*%")
    return return_data if data.blank?

    data.each do |data_row|
      return_data["#{data_row.mock_http_verb}#{ENV['HEADER_DELIMITER']}#{data_row.mock_request_url}"] = data_row.id
    end
    return return_data
  end
end
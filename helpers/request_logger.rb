module ApplicationHelper

  def log_incoming_request
    if !request.env['PATH_INFO'].match(/^\/api\/requestlog/)
      httprequestslog = Httprequestlog.new
      httprequestslog.save_http_request(request)
      httprequestslog.save!
    end
  end
end
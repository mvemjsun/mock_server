module ApplicationHelper

  def log_incoming_request
    httprequestslog = Httprequestlog.new
    httprequestslog.save_http_request(request)
    httprequestslog.save!
  end
end
module ApplicationHelper

  def log_incoming_request
    if !request.env['PATH_INFO'].match(/^\/api\/requestlog/)
      httprequestslog = Httprequestlog.new
      httprequestslog.save_http_request(request)
      begin
        sleep 0.5
        httprequestslog.save!
      rescue ActiveRecord::StatementInvalid
        sleep 0.5
        httprequestslog.save! #Retry
        p 'Successfully retried Statement Invalid'
      rescue Exception
        sleep 0.5
        httprequestslog.save! #Retry
        p 'Successfully retried Exception'
      end
    end
  end
end
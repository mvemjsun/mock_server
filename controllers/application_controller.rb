class ApplicationController < Sinatra::Base
  helpers ApplicationHelper
  helpers Sinatra::Cookies

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)
  set :bind, '0.0.0.0'

  configure :production, :development do
    # enable :logging
    enable :session
    set :session_secret, 'av3rys3cr3tk3y'
    use Rack::CommonLogger, $logger
  end


  before do
    $logger.debug '@' * 80
    $logger.debug "Starting to process #{request.url}"
    $logger.debug '@' * 80

    process_before_script
  end

  after do
    process_after_script
    ActiveRecord::Base.clear_active_connections!
  end

  get '/environment' do
    @title = 'Set mock environment'
    haml :set_mock_environment
  end

  post '/environment' do
    @title = 'Mock set successfully'
    env = %w{integration quality production}
    supplied_env = params[:mock_environment].downcase
    if env.include? supplied_env
      ENV['TEST_ENV'] = supplied_env
      haml_info = {success: true, message: "Test environment set to #{supplied_env}"}
      haml :test_environment_ack, :locals => haml_info
    else
      haml_info = {success: false, message: "Test environment cannot be #{supplied_env} only #{env} supported."}
      haml :test_environment_ack, :locals => haml_info
    end
  end

  post '/latency/:seconds' do
    if params['seconds'].is_i?
      ENV['LATENCY'] = params['seconds']
      status 200
      body "Latency set to #{params['seconds']} second(s)."
    else
      status 400
      body 'Latency could not be set.'
    end
  end

  get '/bird' do
    @title = 'Mocking bird'
    haml :mocking_bird
  end

  get "/*" do
    @title = 'Mock GET'
    # Process the URL
    process_http_verb
  end

  post "/*" do
    @title = 'Mock POST'
    # Process the URL
    process_http_verb
  end

  put "/*" do
    @title = 'Mock PUT'
    # Process the URL
    process_http_verb
  end

  delete "/*" do
    @title = 'Mock DELETE'
    # Process the URL
    process_http_verb
  end
end


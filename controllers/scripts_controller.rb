class MockServerController < ApplicationController

  get '/create/script' do
    @title = 'Create script'
    haml :create_ruby_script, locals: {rubyscript: nil}
  end

  #
  # ???????????
  #
  post '/create/script' do
    @title = 'Script created'
    begin
      if params[:id].length == 0
        rubyScript = Rubyscript.new
        rubyScript.script_name = params[:script_name]
        rubyScript.script_body = params[:script_body]
        rubyScript.save!
      else
        rubyScript = Rubyscript.where(id: params[:id].to_i)
        if rubyScript.any?
          rubyScript.first.script_body = params[:script_body]
          rubyScript.first.save!
        else
        end
      end
    rescue ActiveRecord::RecordNotUnique => errors
      session[:errors] = ['Script name is not unique.']
    rescue ActiveRecord::ActiveRecordError => errors
      session[:errors] = [errors.message]
    end
    p session[:errors] if session[:errors]

    if rubyScript.any?
      haml :create_ruby_script, locals: {rubyscript: rubyScript.first}
    else
      haml :create_ruby_script, locals: {rubyscript: nil}
    end
  end

  get '/script/update/:id' do
    @title = 'Update script'
    script_data = Rubyscript.where(id: params[:id].to_i)
    if script_data.any?
      haml :create_ruby_script, locals: {rubyscript: script_data.first}
    else
      session[:errors] = [response[:message]]
      redirect '/mock/script/search'
    end
  end

  get '/script/search' do
    @title = 'Search scripts'
    haml :search_scripts, locals: {search_data: nil, search_message: nil}
  end

  get '/script/search/results' do
    @title = 'Search scripts - results'
    search_message = nil
    search_data = search_script_data({script_name: params[:script_name]})
    search_message = 'No data found' unless search_data
    haml :search_scripts, locals: {search_data: search_data, search_message: search_message}
  end
end
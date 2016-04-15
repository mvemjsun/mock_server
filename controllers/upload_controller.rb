class MockServerController < ApplicationController

  get '/upload/image' do
    @title = 'Upload Image'
    haml :upload_image, locals: {upload_status: nil}
  end

  post '/upload/image' do
    @title = 'Upload Image'
    error = false

    if (params.has_key? 'image_file_name')
      msg = nil
      upload_file_name = params['image_file_name'][:filename]
      upload_temp_file = params['image_file_name'][:tempfile]
      upload_size = upload_temp_file.size
      allowed_size = ENV['MAX_UPLOAD_SIZE'].nil? ? 500000 : ENV['MAX_UPLOAD_SIZE']
      actual_file_name_uploaded = upload_file_name.gsub(' ', '_')

      if upload_size.to_i > allowed_size.to_i
        msg = 'File size is greater than max allowed file size. Upload failed.'
        error = true
      end

      if params['image_file_name'][:type].match(/^image\//)
      else
        msg = 'Only image files can be uploaded here. Upload failed.'
        error = true
      end

      if !error
        begin
          File.open('public/upload/' + actual_file_name_uploaded, 'w') do |f|
            f.write(upload_temp_file.read)
            msg = "File name #{actual_file_name_uploaded} uploaded successfully."
          end
        rescue => e
          msg = "#{e.message}. Upload Failed."
        end
      end
    else
      msg = 'Filename must be supplied. Upload failed.'
      error = true
    end
    haml :upload_image, locals: {upload_status: msg}
  end

end
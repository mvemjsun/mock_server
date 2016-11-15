require_relative 'spec_helper'

describe 'Mock server' do

  it 'should return http 200 for a known url' do
    TestHelper.insert_mock_row_into_db({mock_name: 'A MOCK GET REQUEST', mock_request_url: 'hello/world', mock_data_response: 'Hi'})
    expect(HTTParty.get('http://localhost:9293/hello/world').code).to eq(200)
  end

  it 'should return http 404 for a unknown url' do
    expect(HTTParty.get('http://localhost:9293/hello/world').code).to eq(404)
  end

  it 'should return http 500 for for the mock set up with http status of 500' do
    TestHelper.insert_mock_row_into_db({mock_name: 'HTTP 500', mock_request_url: 'hello/world', mock_http_status: 500})
    expect(HTTParty.get('http://localhost:9293/hello/world').code).to eq(500)
  end

  it 'should serve the correct response body' do
    TestHelper.insert_mock_row_into_db({mock_name: 'A MOCK GET REQUEST', mock_request_url: 'hello/world', mock_data_response: 'Hi'})
    expect(HTTParty.get('http://localhost:9293/hello/world').body).to eq('Hi')
  end

  it 'should serve the correct text/plain content-type header' do
    TestHelper.insert_mock_row_into_db({mock_name: 'A MOCK GET REQUEST', mock_request_url: 'hello/world', mock_data_response: 'Hi'})
    expect(HTTParty.get('http://localhost:9293/hello/world').headers["content-type"]).to eq('text/plain;charset=utf-8')
  end

  it 'should serve the correct application/json content-type header' do
    TestHelper.insert_mock_row_into_db({mock_name: 'A MOCK GET REQUEST', mock_request_url: 'hello/world', mock_data_response: '{}', mock_content_type: 'application/json;charset=utf-8'})
    expect(HTTParty.get('http://localhost:9293/hello/world').headers["content-type"]).to eq('application/json;charset=utf-8')
    expect(HTTParty.get('http://localhost:9293/hello/world').headers['x']).to eq('y')
  end

  it 'should return http 404 when a url is disabled' do
    TestHelper.insert_mock_row_into_db({mock_name: 'A MOCK GET REQUEST', mock_request_url: 'hello/world',mock_state: false, mock_data_response: 'Hi'})
    expect(HTTParty.get('http://localhost:9293/hello/world').code).to eq(404)
  end

  it 'should correctly replace the response body with the replace data' do
    TestHelper.insert_mock_row_into_db({mock_name: 'A MOCK GET REQUEST', mock_request_url: 'hello/world', mock_data_response: 'hello to me'})
    TestHelper.insert_row_into_replace_data({replaced_string: 'hello to me',
                                             replacing_string: 'hola to me',})
    expect(HTTParty.get('http://localhost:9293/hello/world').body).to eq('hola to me')
  end

end
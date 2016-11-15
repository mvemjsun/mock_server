require_relative 'spec_helper'

describe 'The mock/create page' do

  before :each do
    visit('/mock/create')
  end

  it 'allows user to create mock data without advanced options', :type => :feature, :js => true do
    TestHelper.create_test_mock TestHelper.mockData
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Mock Data - CREATED')
  end

  it 'does not allow to create mock data with same url enabled more than once in a test environment' do
    TestHelper.insert_mock_row_into_db
    TestHelper.create_test_mock TestHelper.mockData
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content 'Only one URL can be active at a time.'
  end

  it 'should not allow a blank mock name' do
    TestHelper.create_test_mock TestHelper.mockData({mock_request_name: ''})
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Mock name can\'t be blank')
  end

  it 'should not allows an empty http status code' do
    TestHelper.create_test_mock TestHelper.mockData({mock_http_status: ''})
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Mock http status can\'t be blank')
  end

  it 'should not allow a blank mock url' do
    TestHelper.create_test_mock TestHelper.mockData({mock_request_url: ''})
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Mock request url can\'t be blank')
  end

  it 'should not an invalid HTTP status code like 900' do
    TestHelper.create_test_mock TestHelper.mockData({mock_http_status: '900'})
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Please enter a valid HTTP code')
  end

  it 'should not an invalid HTTP status code like abcd' do
    TestHelper.create_test_mock TestHelper.mockData({mock_http_status: 'abcd'})
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Please enter a valid HTTP code')
  end

  it 'should give a warning if a JSON content type response is not created with a valid JSON body' do
    TestHelper.create_test_mock TestHelper.mockData({mock_content_type: 'application/json;charset=UTF-8',
                                                     mock_http_body: 'not a json'})
    TestHelper.submit_form_to_create_update_mock_data
    expect(page).to have_content('Response Body is not a Valid JSON')
  end

end

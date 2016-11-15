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

end

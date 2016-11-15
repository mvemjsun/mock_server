describe 'Mock server search feature' do

  before :each do
    visit('/mock/search')
  end

  it 'Should have have option to search a mock using URL' do
    expect(page).to have_css('input#search_mock_request_url')
  end

  it 'Should have have option to search a mock using Mock name' do
    expect(page).to have_css('input#search_mock_name')
  end

  it 'Should return search result(s) using mock name' do
    TestHelper.insert_mock_row_into_db({mock_name: 'REQUEST 1', mock_request_url: 'hello/world1', mock_data_response: 'Hi1'})
    TestHelper.insert_mock_row_into_db({mock_name: 'REQUEST 2', mock_request_url: 'hello/world2', mock_data_response: 'Hi2'})
    fill_in('search_mock_name', with: 'REQUEST')
    click_button('Search')
    expect(page).to have_content ('REQUEST 1')
    expect(page).to have_link('1', href: '/mock/update/1')
    expect(page).to have_content ('REQUEST 2')
    expect(page).to have_link('2', href: '/mock/update/2')
  end

  it 'Should return search result(s) using mock url' do
    TestHelper.insert_mock_row_into_db({mock_name: 'REQUEST 1', mock_request_url: 'hello/world1', mock_data_response: 'Hi1'})
    TestHelper.insert_mock_row_into_db({mock_name: 'REQUEST 2', mock_request_url: 'hello/world2', mock_data_response: 'Hi2'})
    fill_in('search_mock_request_url', with: 'hello')
    click_button('Search')
    expect(page).to have_content ('REQUEST 1')
    expect(page).to have_link('1', href: '/mock/update/1')
    expect(page).to have_content ('REQUEST 2')
    expect(page).to have_link('2', href: '/mock/update/2')
  end

  it 'Should allow to search and select details of a search result' do
    TestHelper.insert_mock_row_into_db({mock_name: 'REQUEST 1', mock_request_url: 'hello/world1', mock_data_response: 'Hi1'})
    TestHelper.insert_mock_row_into_db({mock_name: 'REQUEST 2', mock_request_url: 'hello/world2', mock_data_response: 'Hi2'})
    fill_in('search_mock_name', with: 'REQUEST')
    click_button('Search')
    click_link('1', href: '/mock/update/1')
    expect(page).to have_content('Mock Server - Create/Update mock data')
    expect(page).to have_css('textarea#json_body')
  end
end
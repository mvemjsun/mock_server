describe 'The mock server should be able to search mock details' do

  before :each do
    data = {
        has_before_script: true,
        before_script_name: 'before_script_name.rb',
        has_after_script: true,
        after_script_name: 'after_script_name.rb',
        mock_cookie: 'cookie_name 987654321'
    }
    TestHelper.insert_mock_row_into_db(data)
    visit('/mock/search')
    fill_in('search_mock_request_url', with: 'a/test/url')
    click_button('Search')
    click_link('1', href: '/mock/update/1')
    click_button('Show Advanced Options')
  end

  it 'Should be able to retrieve details of an existing mock' do
    expect(find('#mock_name').value).to eq('TEST MOCK 1')
    expect(find('#mock_http_status').value).to eq('200')
    expect(find('#chk_mock_state').value).to eq('1')
    expect(find('#mock_request_url').value).to eq('a/test/url')
    expect(page).to have_select('sl_mock_http_verb', selected: 'GET')

    expect(page).to have_select('sl_mock_environment', selected: 'production')
    expect(page).to have_select('id_mock_content_type', selected: 'text/plain')
    expect(find('#mock_data_response_headers').value).to eq('x:==:y')

    expect(find('#chk_has_before_script').value).to eq('1')
    expect(find('#chk_has_after_script').value).to eq('1')
    expect(find('#before_script_name').value).to eq('before_script_name.rb')
    expect(find('#after_script_name').value).to eq('after_script_name.rb')
    expect(find('#mock_cookie').value).to eq('cookie_name 987654321')
  end

  it 'Should be able to update an attribute of the mock data' do
    fill_in('mock_http_status', with: 503)
    select 'POST', :from => 'sl_mock_http_verb'
    click_button('Create/Update Mock Data')
    expect(page).to have_content('Mock Data - UPDATED')

    click_link('Search', href: '/mock/search')
    fill_in('search_mock_request_url', with: 'a/test/url')
    click_button('Search')
    expect(page).to have_content('503')
    expect(page).to have_content('POST')
  end

end
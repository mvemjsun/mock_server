require_relative 'spec_helper'

describe 'The mock/create page' do

  before :each do
    visit('/mock/create')
  end

  it 'has all the needed form fields' do

    expect(page).to have_field('mock_name')
    expect(page).to have_field('mock_http_status')
    expect(page).to have_field('chk_mock_state', {checked: false})

    expect(page).to have_field('mock_request_url')
    expect(page).to have_button('clone_headers_button')
    expect(page).to have_button('get_button', {disabled: true})

    expect(page).to have_select('sl_mock_http_verb')
    expect(page).to have_select('sl_mock_environment')
    expect(page).to have_select('id_mock_content_type')
    expect(page).to have_field('mock_data_response_headers')

    expect(page).to have_button('advanced_button')

    expect(page).to have_field('mock_data_response')

    expect(page).not_to have_unchecked_field('chk_has_before_script')
    expect(page).not_to have_field('before_script_name')

    expect(page).not_to have_unchecked_field('chk_has_after_script')
    expect(page).not_to have_field('after_script_name')

    expect(page).not_to have_field('mock_cookie')

    expect(page).to have_button('Create/Update Mock Data')
  end

  it 'shows the advanced options when the show advanced button is clicked' do

    click_button('Show Advanced Options')

    expect(page).to have_unchecked_field('chk_has_before_script')
    expect(page).to have_field('before_script_name')

    expect(page).to have_unchecked_field('chk_has_after_script')
    expect(page).to have_field('after_script_name')

    expect(page).to have_field('mock_cookie')
  end

  it 'should have the link to Mock Env page' do
    expect(page).to have_link('Mock Env')
    expect(page).to have_selector(:css, 'a[href="/environment"]')
  end

  it 'should have the link to Search' do
    expect(page).to have_link('Search')
    expect(page).to have_selector(:css, 'a[href="/mock/search"]')
  end

  it 'should have the link to clone in batch' do
    expect(page).to have_link('Clone Many')
    expect(page).to have_selector(:css, 'a[href="/mock/clone/batch"]')
  end

  it 'should have the link to search missed mock requests' do
    expect(page).to have_link('Misses')
    expect(page).to have_selector(:css, 'a[href="/mock/search/misses"]')
  end

  it 'should have the link to create replace data' do
    expect(page).to have_link('Replace')
    expect(page).to have_selector(:css, 'a[href="/mock/replace/create_update"]')
  end

  it 'should have the link to search replace data' do
    expect(page).to have_link('Replace Search')
    expect(page).to have_selector(:css, 'a[href="/mock/replace/search"]')
  end

  it 'should have the link to upload image' do
    expect(page).to have_link('Upload Image')
    expect(page).to have_selector(:css, 'a[href="/mock/upload/image"]')
  end

  it 'should have the link to create before and after ruby scripts' do
    expect(page).to have_link('Script')
    expect(page).to have_selector(:css, 'a[href="/mock/create/script"]')
  end

  it 'should have the link to search before and after ruby scripts' do
    expect(page).to have_link('Search Script')
    expect(page).to have_selector(:css, 'a[href="/mock/script/search"]')
  end
end